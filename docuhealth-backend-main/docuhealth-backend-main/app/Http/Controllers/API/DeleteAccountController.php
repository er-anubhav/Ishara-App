<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\Share;
use App\Models\DeletedAccount;
use App\Library\Structure;
use Validator;

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
        if ($profile = UserProfile::find($request->profile->id)) {
            
            if (true) {

                try {

                    $user = User::find($this->user_id);
                    $profiles = $user->profiles();
                    foreach ($profiles as $profile) {
                        
                        $profile->delete();

                        //delete all the shared files by this user.
                        Share::where('profile_id', $profile->id)->delete();
                    }

                    //owner account delete.
                    $profile->delete();

                    //delete all the shared files by this user.
                    Share::where('profile_id', $profile->id)->delete();

                    //token block
                    $token = auth('api')->invalidate(true);

                    //store deleted account details in the database.
                    DeletedAccount::create([
                                            'user_id' => $user->id,
                                            'name' => $user->name,
                                            'email' => $user->email,
                                            'phone' => $user->phone,
                                            'deleted_at' => date('Y-m-d H:i:s')
                                        ]);

                    $user->delete();
                    return response()->json($this->structure(true, 'Account Deleted!'), 200);
                } catch (\Exception $e) {
                    return $e;
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                }
            }
            return response()->json($this->structure(true, 'Only account owner can delete the account!'), 200);
        }
        return response()->json($this->structure(false, 'Profile not found'), 200);
    }

}
