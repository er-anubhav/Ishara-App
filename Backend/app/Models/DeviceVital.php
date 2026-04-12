<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use DateTimeInterface;

class DeviceVital extends Model
{
    use HasFactory;

    protected $table = 'device_vitals';

    protected $fillable = [
        'profile_id',
        'device_name',
        'vital_type',
        'value',
        'unit',
        'recorded_at',
    ];

    protected $casts = [
        'value' => 'decimal:2',
        'recorded_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $hidden = [];

    /**
     * Vital type constants matching the BLE protocol
     */
    const TYPE_BODY_TEMP = 'Body_Temp';
    const TYPE_SPO2 = 'SpO2';
    const TYPE_BP_SYS = 'BP_SYS';
    const TYPE_BP_DIA = 'BP_DIA';

    /**
     * Unit mappings for each vital type
     */
    const UNITS = [
        self::TYPE_BODY_TEMP => '°C',
        self::TYPE_SPO2 => '%',
        self::TYPE_BP_SYS => 'mmHg',
        self::TYPE_BP_DIA => 'mmHg',
    ];

    /**
     * Valid vital types
     */
    public static function validTypes(): array
    {
        return [
            self::TYPE_BODY_TEMP,
            self::TYPE_SPO2,
            self::TYPE_BP_SYS,
            self::TYPE_BP_DIA,
        ];
    }

    /**
     * Scope to filter by profile
     */
    public function scopeProfile($query, $profileId)
    {
        return $query->where('profile_id', $profileId);
    }

    /**
     * Scope to filter by device name
     */
    public function scopeDevice($query, $deviceName)
    {
        return $query->where('device_name', $deviceName);
    }

    /**
     * Scope to filter by vital type
     */
    public function scopeType($query, $type)
    {
        return $query->where('vital_type', $type);
    }

    /**
     * Scope to filter by date range
     */
    public function scopeDateRange($query, $startDate, $endDate = null)
    {
        $query->whereDate('recorded_at', '>=', $startDate);
        if ($endDate) {
            $query->whereDate('recorded_at', '<=', $endDate);
        }
        return $query;
    }

    /**
     * Get the latest reading for each vital type for a device
     */
    public static function latestByDevice($deviceName, $profileId = null)
    {
        $query = static::where('device_name', $deviceName);
        
        if ($profileId) {
            $query->where('profile_id', $profileId);
        }

        return $query->orderBy('recorded_at', 'desc')
                     ->get()
                     ->unique('vital_type');
    }

    /**
     * Create a vital reading from MQTT payload
     * MQTT format: {device_name: [{vital_type: value}]}
     */
    public static function createFromMqttPayload(string $payload, ?int $profileId = null): array
    {
        $created = [];
        $data = json_decode($payload, true);

        if (!is_array($data)) {
            return $created;
        }

        foreach ($data as $deviceName => $readings) {
            if (!is_array($readings)) {
                continue;
            }

            foreach ($readings as $reading) {
                if (!is_array($reading)) {
                    continue;
                }

                foreach ($reading as $vitalType => $value) {
                    if (!in_array($vitalType, self::validTypes())) {
                        continue;
                    }

                    // Handle temperature (sent as value * 10)
                    $finalValue = $value;
                    if ($vitalType === self::TYPE_BODY_TEMP && $value > 100) {
                        $finalValue = $value / 10.0;
                    }

                    $vital = static::create([
                        'profile_id' => $profileId,
                        'device_name' => $deviceName,
                        'vital_type' => $vitalType,
                        'value' => $finalValue,
                        'unit' => self::UNITS[$vitalType] ?? null,
                        'recorded_at' => now(),
                    ]);

                    $created[] = $vital;
                }
            }
        }

        return $created;
    }

    /**
     * Format date for JSON serialization
     */
    protected function serializeDate(DateTimeInterface $date): string
    {
        return $date->format('Y-m-d H:i:s');
    }

    /**
     * Get relationship with UserProfile
     */
    public function profile()
    {
        return $this->belongsTo(UserProfile::class, 'profile_id');
    }
}
