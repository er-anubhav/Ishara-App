<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
// use App\Mail\EmailVerificationMail;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\DisplayPath;
use App\Models\User;
use App\Models\UserProfile;
use DB;
use Str;

class RegisterController extends Controller
{
    // Structure of response API.
    use Structure;

    /**
     * User Login.
     *
     * @return \Illuminate\Http\Response
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), 
        [ 
          'name' => 'required',
          'email' => 'nullable|email',
        ]);

        if (!$validator->fails()) {
            
            if (User::where('email', $request->email)->where('id', '!=', auth('api')->user()->id)->first()) {
                return response()->json($this->structure(false, 'The email has already been taken.'), 200);
            }

            $user = User::find(auth('api')->user()->id);
            
            if ($user) {

                if ($user->is_active == 'Yes') {
                    
                    $user->name = $request->name;
                    $user->email = $request->email;

                    if ($user->save()) {

                        //beautify user data.
                        $beautify = new Beautify();
                        $user = $beautify->userOBJ($user);

                        $data['user'] = $user;
                        $data['profiles'] = $user->profiles;
                        if (count($data['profiles']) === 0) {
                            $profiles = UserProfile::create(['user_id' => $user->id]);
                            $profiles->name = 'User1';
                            $profiles->icon = DisplayPath::user_profile_default_icon();
                            $data['profiles'] = [$profiles];
                        }

                        return response()->json($this->structure(true, "Success!", $data), 200);
                    }
                    return response()->json($this->structure(false, 'Somehting Went Wrong!'), 200);
                } 
                return response()->json($this->structure(false, "Your account is temporary In-active."), 200);
            }
            return response()->json($this->structure(false, "Somehting Went Wrong!"), 200);
        } 
        return response()->json($this->structure(false, $validator->errors()->first()), 200);
    }

    public function email_verification_request(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required',
        ]);

        if (!$validator->fails()) {
            
            $user = User::find( isset(Auth::guard('api')->user()->id) ? Auth::guard('api')->user()->id : 0 );

            if ($user) {

                //Check user is email already have another user.
                $emailExist = User::where('is_active', 'Yes')->where('id', '!=', $user->id)
                                    ->where('email', $request->email)->first();

                if ($emailExist) {
                    return response()->json($this->structure(false, "Email is already exist!"), 200);
                } 
                $token = Str::random(60);
                $input['link'] = url('api/v1').'/email-verify?email='.$request->email.'&token='.$token;
                $input['name'] = ucwords($user->last_name ? $user->first_name.' '.$user->last_name : $user->first_name);
                $responce = Mail::to($request->email)->send(new EmailVerificationMail($input));
                
                $user->remember_token = $token;
                $user->email = $request->email;

                if ($user->save()) {
                    return response()->json($this->structure(true, "Verification mail has sent successfully"), 200);
                }
                return response()->json($this->structure(false, 'Something went wrong !,please try again.'), 200);
            }
            return response()->json($this->structure(false, "Unauthorised access!"), 200);
        } 
        return response()->json($this->structure(false, $validator->errors()->first()), 200);
    }

    /**
     * Mobile Number OR OTP Varify.
     *
     * @return \Illuminate\Http\Response
     */
    public function verify_email(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'token' => 'required',
        ]);
        if (!$validator->fails()) {

            $user = User::where('email', $request->email)->where('role_id', '1')->orderBy('id', 'desc')->first();

            if (!empty($user)) {

                if ($request->token != $user->remember_token) {
                    return view('api-response-page', ['success' => false, 'title' => 'Invalid or expired token :(', 'message' => 'Your verification token is invalid, Please send the new email verification request.']);
                }
                if ($user->is_active == 'Yes') {
                  
                    $user->email_verified_at = date('Y-m-d H:i:s');
                    $user->updated_at = date('Y-m-d H:i:s');

                    if ($user->save()) {
                        return view('api-response-page', ['success' => true, 'title' => 'Your Email has verified successfully', 'message' => 'Now you can proceed the profile setup process.']);
                    }
                    return view('api-response-page', ['success' => false, 'title' => 'Something Went Wrong :(', 'message' => 'Please retry the verification process, If you still face this issue then please contact us.']);
                }
                return view('api-response-page', ['success' => false, 'title' => 'User access is blocked :(', 'message' => 'This email address or account is blocked!!']);
            } 
            return view('api-response-page', ['success' => false, 'title' => 'Email Not Found :(', 'message' => 'Your email is not found in our records, If your email is correct & registered then please contact us with your registered mobile number.']);
        } 
        return view('error-404');
    }

    public function email__is_verified(Request $request)
    {
        $data = auth("api")->user();
        if(!empty($data) && isset(Auth::guard('api')->user()->id))
        {
            $user = User::find(Auth::guard('api')->user()->id);

            if (!empty($user)) {

                if ($user->email_verified_at) {
                    return response()->json($this->structure(true, 'Email is verified!', ['isVerified' => true]), 200);
                }
                return response()->json($this->structure(true, 'Email is not verified!', ['isVerified' => false]), 200);
            } 
            return response()->json($this->structure(false, 'Invalid credentials!'), 200);
        } 
        return response()->json($this->structure(false, 'Unauthorised access'), 200);
    }


} //Class End Tag.
