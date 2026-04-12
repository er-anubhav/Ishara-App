<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\DeletedAccount;
use App\Library\Structure;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class DeleteAccountController extends Controller
{
    // Structure of response API.
    use Structure;

    private $user_id;
    
    public function __construct()
    {
        $this->user_id = isset(auth('api')->user()->id) ? auth('api')->user()->id : 0;
    }


    /**
     * Delete All the profiles.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function delete(Request $request)
    {
        if (!isset($request->profile->id) || !UserProfile::find($request->profile->id)) {
            return response()->json($this->structure(false, 'Profile not found'), 200);
        }

        try {
            $user = User::find($this->user_id);
            if (!$user) {
                return response()->json($this->structure(false, 'User not found!'), 200);
            }

            $profiles = $user->profiles();
            foreach ($profiles as $userProfile) {
                $this->deleteProfileData((int) $userProfile->id);
                $userProfile->delete();
            }

            DeletedAccount::create([
                'user_id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'deleted_at' => now(),
            ]);

            auth('api')->invalidate(true);
            $user->delete();

            return response()->json($this->structure(true, 'Account Deleted!'), 200);
        } catch (\Throwable $e) {
            Log::error('Delete account failed', [
                'user_id' => $this->user_id,
                'profile_id' => $request->profile->id ?? null,
                'message' => $e->getMessage(),
            ]);
            return response()->json($this->structure(false, 'Internal server error!'), 200);
        }
    }

    private function deleteProfileData(int $profileId): void
    {
        $this->deleteWhere('bookmarks', 'profile_id', $profileId);
        $this->deleteWhere('device_vitals', 'profile_id', $profileId);
        $this->deleteWhere('measurements', 'profile_id', $profileId);
        $this->deleteWhere('reminders', 'profile_id', $profileId);
        $this->deleteWhere('files', 'profile_id', $profileId);
        $this->deleteWhere('folders', 'profile_id', $profileId);

        if (Schema::hasTable('share')) {
            DB::table('share')
                ->where('profile_id', $profileId)
                ->orWhere('shared_by', $profileId)
                ->delete();
        }
    }

    private function deleteWhere(string $table, string $column, int $value): void
    {
        if (!Schema::hasTable($table) || !Schema::hasColumn($table, $column)) {
            return;
        }

        DB::table($table)->where($column, $value)->delete();
    }

}
