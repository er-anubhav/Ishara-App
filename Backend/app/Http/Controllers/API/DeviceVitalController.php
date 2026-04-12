<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Library\Structure;
use App\Models\DeviceVital;
use Carbon\Carbon;
use DB;

class DeviceVitalController extends Controller
{
    use Structure;

    /**
     * Store a vital reading from the device/app
     * 
     * Expected payload format (matching MQTT):
     * {
     *   "device_name": "DeviceName",
     *   "vital_type": "SpO2",
     *   "value": 97
     * }
     * 
     * OR MQTT format:
     * {
     *   "DeviceName": [{"SpO2": 97}]
     * }
     */
    public function store(Request $request)
    {
        $profile_id = $request->profile->id ?? null;

        // Check if it's MQTT format (device_name as key)
        $rawData = $request->all();
        $firstKey = array_key_first($rawData);
        
        if ($firstKey && is_array($rawData[$firstKey] ?? null)) {
            // MQTT format: {device_name: [{vital_type: value}]}
            $payload = json_encode($rawData);
            $created = DeviceVital::createFromMqttPayload($payload, $profile_id);
            
            if (empty($created)) {
                return response()->json($this->structure(false, 'Invalid payload format'), 200);
            }
            
            return response()->json($this->structure(true, 'Vital(s) saved', [
                'count' => count($created),
                'vitals' => $created
            ]), 200);
        }

        // Standard format
        $validator = Validator::make($request->all(), [
            'device_name' => 'required|string|max:100',
            'vital_type' => 'required|string|in:' . implode(',', DeviceVital::validTypes()),
            'value' => 'required|numeric',
            'recorded_at' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        try {
            $value = $request->value;
            
            // Handle temperature (may be sent as value * 10)
            if ($request->vital_type === DeviceVital::TYPE_BODY_TEMP && $value > 100) {
                $value = $value / 10.0;
            }

            $vital = DeviceVital::create([
                'profile_id' => $profile_id,
                'device_name' => $request->device_name,
                'vital_type' => $request->vital_type,
                'value' => $value,
                'unit' => DeviceVital::UNITS[$request->vital_type] ?? null,
                'recorded_at' => $request->recorded_at ? Carbon::parse($request->recorded_at) : now(),
            ]);

            return response()->json($this->structure(true, 'Vital saved', $vital), 200);

        } catch (\Exception $e) {
            return response()->json($this->structure(false, 'Failed to save vital: ' . $e->getMessage()), 200);
        }
    }

    /**
     * Store vitals via MQTT webhook (public endpoint for MQTT broker callback)
     * No authentication required - data comes directly from MQTT broker
     */
    public function mqttWebhook(Request $request)
    {
        $payload = $request->getContent();
        
        // Log incoming webhook
        \Log::info('MQTT Webhook received', ['payload' => $payload]);
        
        $created = DeviceVital::createFromMqttPayload($payload);
        
        if (empty($created)) {
            return response()->json(['success' => false, 'message' => 'No valid vitals in payload'], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Vitals saved',
            'count' => count($created)
        ], 200);
    }

    /**
     * Get vitals for the authenticated profile
     */
    public function get(Request $request)
    {
        $profile_id = $request->profile->id ?? null;
        
        if (!$profile_id) {
            return response()->json($this->structure(false, 'Profile not found'), 200);
        }

        $query = DeviceVital::profile($profile_id);

        // Filter by device name
        if ($request->device_name) {
            $query->device($request->device_name);
        }

        // Filter by vital type
        if ($request->vital_type) {
            $query->type($request->vital_type);
        }

        // Filter by date
        if ($request->date) {
            $query->whereDate('recorded_at', Carbon::parse($request->date));
        }

        // Filter by date range
        if ($request->start_date) {
            $query->dateRange(
                Carbon::parse($request->start_date),
                $request->end_date ? Carbon::parse($request->end_date) : null
            );
        }

        // Order and limit
        $query->orderBy('recorded_at', 'desc');
        
        $limit = min($request->limit ?? 100, 500);
        $vitals = $query->limit($limit)->get();

        return response()->json($this->structure(true, 'Device vitals', $vitals), 200);
    }

    /**
     * Get latest vitals for all types (dashboard view)
     */
    public function latest(Request $request)
    {
        $profile_id = $request->profile->id ?? null;
        
        if (!$profile_id) {
            return response()->json($this->structure(false, 'Profile not found'), 200);
        }

        $deviceName = $request->device_name;
        
        // Get latest reading for each vital type
        $latestVitals = DeviceVital::profile($profile_id)
            ->when($deviceName, fn($q) => $q->device($deviceName))
            ->select('vital_type', DB::raw('MAX(id) as latest_id'))
            ->groupBy('vital_type')
            ->pluck('latest_id');

        $vitals = DeviceVital::whereIn('id', $latestVitals)
            ->orderBy('vital_type')
            ->get()
            ->keyBy('vital_type');

        // Build response with all vital types
        $result = [];
        foreach (DeviceVital::validTypes() as $type) {
            $vital = $vitals->get($type);
            $result[$type] = $vital ? [
                'value' => $vital->value,
                'unit' => $vital->unit,
                'device_name' => $vital->device_name,
                'recorded_at' => $vital->recorded_at,
            ] : null;
        }

        return response()->json($this->structure(true, 'Latest vitals', $result), 200);
    }

    /**
     * Get analytics/history for a specific vital type
     */
    public function analytics(Request $request)
    {
        $profile_id = $request->profile->id ?? null;
        
        if (!$profile_id) {
            return response()->json($this->structure(false, 'Profile not found'), 200);
        }

        $validator = Validator::make($request->all(), [
            'vital_type' => 'required|in:' . implode(',', DeviceVital::validTypes()),
            'period' => 'nullable|in:day,week,month,custom',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $vitalType = $request->vital_type;
        $period = $request->period ?? 'day';
        
        // Calculate date range based on period
        $endDate = Carbon::today();
        switch ($period) {
            case 'week':
                $startDate = Carbon::today()->subDays(6);
                break;
            case 'month':
                $startDate = Carbon::today()->subDays(29);
                break;
            case 'custom':
                $startDate = $request->start_date ? Carbon::parse($request->start_date) : Carbon::today();
                $endDate = $request->end_date ? Carbon::parse($request->end_date) : Carbon::today();
                break;
            default: // day
                $startDate = Carbon::today();
                break;
        }

        $vitals = DeviceVital::profile($profile_id)
            ->type($vitalType)
            ->whereDate('recorded_at', '>=', $startDate)
            ->whereDate('recorded_at', '<=', $endDate)
            ->orderBy('recorded_at', 'asc')
            ->get();

        // Calculate statistics
        $values = $vitals->pluck('value');
        $stats = [
            'min' => $values->min(),
            'max' => $values->max(),
            'avg' => round($values->avg(), 2),
            'count' => $vitals->count(),
        ];

        // Group by date for chart data
        $grouped = $vitals->groupBy(fn($v) => Carbon::parse($v->recorded_at)->format('Y-m-d'));
        $chartData = [];
        foreach ($grouped as $date => $dateVitals) {
            $chartData[] = [
                'date' => $date,
                'readings' => $dateVitals->map(fn($v) => [
                    'time' => Carbon::parse($v->recorded_at)->format('H:i'),
                    'value' => $v->value,
                ])->values(),
            ];
        }

        return response()->json($this->structure(true, 'Vital analytics', [
            'vital_type' => $vitalType,
            'unit' => DeviceVital::UNITS[$vitalType] ?? null,
            'period' => $period,
            'start_date' => $startDate->format('Y-m-d'),
            'end_date' => $endDate->format('Y-m-d'),
            'statistics' => $stats,
            'data' => $chartData,
        ]), 200);
    }

    /**
     * Delete a vital reading
     */
    public function delete(Request $request, $id)
    {
        $profile_id = $request->profile->id ?? null;
        
        if (!$profile_id) {
            return response()->json($this->structure(false, 'Profile not found'), 200);
        }

        $vital = DeviceVital::profile($profile_id)->find($id);
        
        if (!$vital) {
            return response()->json($this->structure(false, 'Vital not found'), 200);
        }

        $vital->delete();

        return response()->json($this->structure(true, 'Vital deleted'), 200);
    }

    /**
     * Link a device to the current profile
     * This allows associating existing device readings with a profile
     */
    public function linkDevice(Request $request)
    {
        $profile_id = $request->profile->id ?? null;
        
        if (!$profile_id) {
            return response()->json($this->structure(false, 'Profile not found'), 200);
        }

        $validator = Validator::make($request->all(), [
            'device_name' => 'required|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        // Update all unlinked vitals from this device to the current profile
        $updated = DeviceVital::where('device_name', $request->device_name)
            ->whereNull('profile_id')
            ->update(['profile_id' => $profile_id]);

        return response()->json($this->structure(true, 'Device linked', [
            'device_name' => $request->device_name,
            'linked_readings' => $updated,
        ]), 200);
    }

    /**
     * Get list of known devices for the profile
     */
    public function devices(Request $request)
    {
        $profile_id = $request->profile->id ?? null;
        
        if (!$profile_id) {
            return response()->json($this->structure(false, 'Profile not found'), 200);
        }

        $devices = DeviceVital::profile($profile_id)
            ->select('device_name', DB::raw('COUNT(*) as reading_count'), DB::raw('MAX(recorded_at) as last_reading'))
            ->groupBy('device_name')
            ->orderBy('last_reading', 'desc')
            ->get();

        return response()->json($this->structure(true, 'Devices', $devices), 200);
    }
}
