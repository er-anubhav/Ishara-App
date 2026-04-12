<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\Message;
use App\Library\Sms;
use App\Models\Secrete;
use App\Models\User;
use App\Models\UserProfile;
use DB;

class AuthController extends Controller
{
    // Structure of response API.
    use Structure;

    /**
     * User Login.
     *
     * @return \Illuminate\Http\Response
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required',
        ]);

        if (!$validator->fails()) {
            
            //Check user is register or not.
            $user = User::where(['phone' => $request->phone])->first();
            
            if ($user) {

                if ($user->is_active == 'Yes') {
                    
                    if ($this->sendSMS($request->phone, $user->id)) {

                        return response()->json($this->structure(true, "OTP send successfully"), 200);
                    }
                    return response()->json($this->structure(false, 'OTP not sent !,please try again.'), 200);
                } 
                return response()->json($this->structure(false, "Your account is temporary In-active."), 200);
            }
            
            if ($this->sendSMS($request->phone)) {

                return response()->json($this->structure(true, "OTP send successfully"), 200);
            }
        } 
        return response()->json($this->structure(false, $validator->errors()->first()), 200);
    }

    /**
     * Mobile Number OR OTP Varify.
     *
     * @return \Illuminate\Http\Response
     */
    public function verify(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|numeric|digits:10',
            'otp' => 'required|numeric',
        ]);
        if (!$validator->fails()) {

            $id = $this->checkUser($request->phone);

            if ($user = User::find($id)) {

                if ($user->is_active == 'No') {
                    return response()->json($this->token_structure(false, 'User access is blocked!'), 200);
                }

                $secrete = DB::table('secretes')->where(['user_id' => $user->id, 'user_type' => 'User', 'otp' => $request->otp, 'is_used' => 0])->first();
            }else{
                $secrete = DB::table('secretes')->where(['phone' => $request->phone, 'user_type' => 'User', 'otp' => $request->otp, 'is_used' => 0])->first();
            }

            if (empty($secrete)) {
                return response()->json($this->token_structure(false, 'Please enter a valid OTP.'), 200);
            }
            // if (strtotime($secrete->expired_at) < strtotime(date('Y-m-d H:i:s'))) {
            //     return response()->json($this->token_structure(false, 'Your OTP is expired.'), 200);
            // }

            //otp: mark as used. 
            DB::table('secretes')->where('id', $secrete->id)->update(['is_used' => 1, 'updated_at' => date('Y-m-d H:i:s')]);

            if (empty($user)) {
                $user = User::create(['phone' => $request->phone]);
            }else{
                $user->updated_at = date('Y-m-d H:i:s');
            }

            if ($user->save()) {

                $token = auth('api')->login($user);

                //login with default profile.
                if ($profile = $user->profile) {
                    unset($profile->icon);
                    $token = auth('api')->claims(['logged_in_profile' => $profile])->login($user);
                }

                //beautify user data.
                $beautify = new Beautify();
                $user = $beautify->userOBJ($user);
                $action = empty($user->name) ? 'go_to_register' : 'go_to_profiles';

                return response()->json($this->action_with_token_structure(true, 'User logged in successfully', [$user], $token, $action), 200);
            }
            return response()->json($this->token_structure(false, 'Something Went Wrong!'), 200);
        } 
        return response()->json($this->token_structure(false, $validator->errors()->first()), 200);
    }

    private function sendSMS($phone, $id = NULL){

        //generate otp.
        $otp = 123456;
        // $otp = mt_rand(100000,999999);

        //generate message.
        // $message = new Message();
        // $msg     = $message->login($otp);
        
        //send otp.
        // $sms     = new Sms($phone, $msg);

        // if ($sms->send()) {
        if (true) { //when use real sms this will comment.

            $prev_request = DB::table('secretes')->where(['phone'=>$phone, 'user_type'=>'User', 'is_used'=>'No'])->first();
            if ($prev_request) {
                return DB::table('secretes')->where('id', $prev_request->id)
                                    ->update(['otp' => $otp, 'created_at' => date("Y-m-d H:i:s")]);
            }
            return DB::table('secretes')->insertGetId(['user_id' => $id, 'user_type' => 'User', 'phone'=> $phone, 'otp' => $otp, 'created_at' => date("Y-m-d H:i:s")]);
        }
        return 0;
    }

    /**
     * User Fetch Or Register.
     *
     * @return \Illuminate\Http\Response
     */
    private function checkUser($phone)
    {
        $user = User::where(['phone' => $phone])->first();
        if(!empty($user))
        {
            return $user->id;
        }
        return 0;
    }

    public function profile_login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'profile_id' => 'required',
        ], ['profile_id.required' => 'Profile not found!']);
        if (!$validator->fails()) {

            $id = isset(auth('api')->user()->id) ? auth('api')->user()->id : 0;

            if ($user = User::find($id)) {

                $profile = UserProfile::where('id', $request->profile_id)
                                    ->exclude(['created_at', 'updated_at', 'deleted_at'])->first();
                if ($profile) {

                    $user->icon = $profile->icon;
                    if ($profile->user_id == $user->id || $profile->parent_id == $user->id) {
                        
                        if ($request->device_token) {
                            $profile->device_token = $request->device_token;
                            $profile->save();
                        }
                        $data['user'] = $user;
                        $data['profile'] = $profile;
                        unset($profile->icon);
                        $token = auth('api')->claims(['logged_in_profile' => $profile])->login($user);
                        return response()->json($this->token_structure(true, $profile->name.' Login Success.', $data, $token), 200);
                    }
                }
            }
            return response()->json($this->token_structure(false, 'Profile not found!'), 200);
        } 
        return response()->json($this->token_structure(false, $validator->errors()->first()), 200);
    }

    public function logout(Request $request){

        $token = auth('api')->user()->token();
        if(!empty($token))
        {
            if ($token->revoke()) {
                return response()->json($this->structure(true, 'Logout successfully'), 200);
            }
        }
        return response()->json($this->structure(false, "Unauthorised access"), 200);
    }

    public function logoutFromAllDevice(Request $request){

        $token = auth('api')->user()->tokens();
        if(!empty($token))
        {
            if ($token->revoke()) {
                return response()->json($this->structure(true, 'Logout successfully'), 200);
            }
        }
        return response()->json($this->structure(false, "Unauthorised access"), 200);
    }

} //Class End Tag.
