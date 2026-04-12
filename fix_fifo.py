import re

with open('/var/www/laravel-backend/app/Http/Controllers/API/MeasurementController.php', 'r') as f:
    content = f.read()

old_code = '''                try {
                    $measurement->save();
                    return response()->json($this->structure(true, 'Measurement Saved'), 200);'''

new_code = '''                try {
                    $measurement->save();
                    
                    // FIFO cleanup for auto-fetched BLE data (max 10,000 per profile)
                    if ($request->is_auto_fetched) {
                        $maxAutoFetched = 10000;
                        $autoFetchedCount = Measurement::profile($profile_id)->where('is_auto_fetched', true)->count();
                        if ($autoFetchedCount > $maxAutoFetched) {
                            $deleteCount = $autoFetchedCount - $maxAutoFetched;
                            $oldestIds = Measurement::profile($profile_id)->where('is_auto_fetched', true)->orderBy('id', 'asc')->limit($deleteCount)->pluck('id');
                            Measurement::whereIn('id', $oldestIds)->delete();
                        }
                    }
                    
                    return response()->json($this->structure(true, 'Measurement Saved'), 200);'''

content = content.replace(old_code, new_code)

with open('/var/www/laravel-backend/app/Http/Controllers/API/MeasurementController.php', 'w') as f:
    f.write(content)

print('FIFO cleanup added successfully')
