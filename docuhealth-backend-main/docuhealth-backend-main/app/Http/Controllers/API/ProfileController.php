<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\Share;
use App\Library\Beautify;
use App\Library\Structure;
use App\Library\TargetPath;
use App\Library\DisplayPath;
use Validator;
use File;
use App\Models\Setting;

class ProfileController extends Controller
{
    // Structure of response API.
    use Structure;

    private $beautify, $user_id;
    
    public function __construct()
    {
        $this->beautify = new Beautify();
        $this->user_id = isset(auth('api')->user()->id) ? auth('api')->user()->id : 0;
    }


    /**
     * Get the authenticated User profiles.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function profiles()
    {
        $user = User::find($this->user_id);

        $profiles = $user->profiles();
        $user = $this->beautify->userOBJ($user);

        $auth_profile = isset(auth('api')->payload()['logged_in_profile']) ? auth('api')->payload()['logged_in_profile'] : [] ;
        $profile_id = isset($auth_profile['id']) ? $auth_profile['id'] : 0 ;

        $user_profiles = [];
        foreach ($profiles as $profile) {
            $profile->active = $profile->id == $profile_id ? true : false ;            
            array_push($user_profiles, $profile);
        }
        $data['user'] = $user;
        $data['profiles'] = $user_profiles;
        return response()->json($this->structure(true, 'Success', $data), 200);
    }

    /**
     * Create the authenticated User Profile.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function create_profile(Request $request)
    {
        $validation_msg = [
            'name.regex' => 'Please Enter a Valid Name.',
            'name.min' => 'Please Enter a Valid Name.',
        ];

        $validator = Validator::make($request->json()->all(), [
            'name' => 'required|regex:/^[\pL\s\-\0-9]+$/u|min:3|max:50',
            'relation' => 'required',
        ], $validation_msg);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        //profile limitations.
        $user = User::find($this->user_id);
        $profiles = $user->profiles();
        $profileCreated = isset($profiles) ? count($profiles) : 0 ;

        $limit = Setting::where('key', 'FAMILY_MEMBERS')->value('value');
        $limit = $limit ? $limit : 4 ;
        if($limit <= $profileCreated){
            return response()->json($this->structure(false, 'Profile limit is exceed!'), 200);
        }

        $createLogin = false;
        if ($request->phone) {
            if ($this->phoneExist($request->phone)) {
                return response()->json($this->structure(false, 'Phone is already exist!'), 200);
            }
            $createLogin = true;
        }

        $icons = ['user.png', 'user-red.png', 'user-blue.png', 'user-green.png', 'user-yellow.png', 'user-black.png'];
        $profile_icon = $icons[array_rand($icons)];

        if (isset($request->profile->id)) {
            
            if ($profile = UserProfile::find($request->profile->id)) {

                $parent_id = $profile->type == 'Self' ? $this->user_id : $profile->parent_id;

                $profile = new UserProfile();
                $profile->parent_id = $parent_id;
                $profile->type = 'Add-On';
                $profile->name = $request->name;
                $profile->dob = $request->dob;
                $profile->icon = $profile_icon;
                $profile->gender = isset($request->gender) ? $request->gender : 'Not specified';
                $profile->relation = $request->relation;
                if ($profile->save()) {
                    if ($createLogin) {
                        $response = $this->add_new_login_access($request->phone, null, $profile->name);
                        if ($response['success'] == false) {
                            return response()->json($this->structure(false, $response['message']), 200);
                        }

                        //add self access to main profile.
                        if (isset($response['data'])) {
                            $profile->user_id = $response['data']->id;
                            $profile->save();
                        }
                    }
                    return response()->json($this->structure(true, "Profile created successfully", $profile), 200);
                }
                return response()->json($this->structure(false, "Something went wrong!"), 200);
            }
            return response()->json($this->structure(false, "Seems like you have not logged in any profile!"), 200);
        }else{

            $profile = new UserProfile();
            $profile->parent_id = $this->user_id;
            $profile->type = 'Add-On';
            $profile->name = $request->name;
            $profile->dob = $request->dob;
            $profile->icon = $profile_icon;
            $profile->gender = isset($request->gender) ? $request->gender : 'Not specified';
            $profile->relation = $request->relation;

            if ($profile->save()) {
                if ($createLogin) {
                    $response = $this->add_new_login_access($request->phone, null, $profile->name);
                    if ($response['success'] == false) {
                        return response()->json($this->structure(false, $response['message']), 200);
                    }

                    //add self access to main profile.
                    if (isset($response['data'])) {
                        $profile->user_id = $response['data']->id;
                        $profile->save();
                    }
                }
                return response()->json($this->structure(true, "Profile created successfully", $profile), 200);
            }
            return response()->json($this->structure(false, "Something went wrong!"), 200);
        }
        
    }

    /**
     * Create the authenticated User Profile.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function update_profile(Request $request)
    {
        $validation_msg = [
            'name.regex' => 'Please Enter a Valid Name.',
            'name.min' => 'Please Enter a Valid Name.',
        ];

        $validator = Validator::make($request->json()->all(), [
            'name' => 'required|regex:/^[\pL\s\-\0-9]+$/u|min:3|max:50',
            'dob' => 'nullable',
            'gender' => 'nullable',
            'relation' => 'nullable',
            'email' => 'nullable|email',
            'phone' => 'nullable|numeric|digits:10',
        ], $validation_msg);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        if (User::where('email', $request->email)->where('id', '!=', $this->user_id)->first()) {
            return response()->json($this->structure(false, 'The email has already been taken.'), 200);
        }

        if($profile = UserProfile::find($request->profile->id)){

            if (!$request->relation && $profile->type !== 'Self') {
                return response()->json($this->structure(false, 'Relation field is required!'), 200);
            }

            if($request->name)
                $profile->name = $request->name;

            if($request->dob)
                $profile->dob = $request->dob;

            if($request->gender)
                $profile->gender = $request->gender;

            if($profile->type !== 'Self')
                $profile->relation = $request->relation;

            if($request->address)
                $profile->address = $request->address;

            if ($profile->save()) {

                if ($profile->type == 'Self') {
                    
                    if ($request->phone != auth('api')->user()->phone) {
                        if (!$this->update_existing_phone($request->phone, $this->user_id)) {
                            return response()->json($this->structure(false, "Phone is already exist!"), 200); 
                        }
                    }

                    if ($request->email != auth('api')->user()->email) {
                        if (!$this->update_existing_email($request->email, $this->user_id)) {
                            return response()->json($this->structure(false, "Email is already exist!"), 200); 
                        }
                    }
                }else{

                    if ($profile->user_id) {
                        $user = User::find($profile->user_id); 
                        if ($request->phone != $user->phone) {
                            if (!$this->update_existing_phone($request->phone, $user->id)) {
                                return response()->json($this->structure(false, "Phone is already exist!"), 200); 
                            }
                        }

                        if ($request->email != $user->email) {
                            if (!$this->update_existing_email($request->email, $user->id)) {
                                return response()->json($this->structure(false, "Email is already exist!"), 200); 
                            }
                        }
                    }else{
                        if ($request->phone) {
                            
                            $response = $this->add_new_login_access($request->phone, $request->email, $profile->name);
                            if ($response['success'] == false) {
                                return response()->json($this->structure(false, $response['message']), 200);
                            }

                            //add self access to main profile.
                            if (isset($response['data'])) {
                                $profile->user_id = $response['data']->id;
                                $profile->save();
                            }
                        }
                    }
                }
                return response()->json($this->structure(true, "Profile updated successfully", $profile), 200);
            }
            return response()->json($this->structure(false, "Something went wrong!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function add_new_login_access($phone, $email = '', $name = '')
    {
        if ($this->phoneExist($phone)) {
            return ['success'=>false, 'message' => 'Phone is already exist!'];
        }

        if ($email) {
            if ($this->emailExist($email)) {
                return ['success'=>false, 'message' => 'Email is already exist!'];
            }
        }else{
            $email = null;
        }

        $user = User::create([
                                'name' => $name,
                                'phone' => $phone,
                                'email' => $email,
                                'created_at' => date('Y-m-d H:i:s'),
                            ]);
        if ($user) {
            return ['success'=>true, 'message' => '', 'data' => $user];
        }

        return ['success'=>false, 'message' => 'Login access creation failed!'];
    }

    public function update_existing_phone($phone, $user_id)
    {
        $exist = $this->phoneExist($phone, $user_id);
        return $exist ? false : User::where('id', $user_id)->update(['phone' => $phone, 'updated_at' => date('Y-m-d H:i:s')]);
    }

    public function update_existing_email($email, $user_id)
    {
        $exist = $this->emailExist($email, $user_id);
        return $exist ? false : User::where('id', $user_id)->update(['email' => $email, 'updated_at' => date('Y-m-d H:i:s')]);
    }

    public function phoneExist($phone, $user_id = 0)
    {
        $exist = User::where('phone', $phone);

        if ($user_id != 0) {
            $exist = $exist->where('id', '!=', $user_id);
        }

        return $exist->first() ? true : false ;
    }

    public function emailExist($email, $user_id = 0)
    {
        $exist = User::where('email', $email);

        if ($user_id != 0) {
            $exist = $exist->where('id', '!=', $user_id);
        }

        return $exist->first() ? true : false ;
    }

    /**
     * Update the authenticated User Profile.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function my_profile(Request $request)
    {
        if ($profile = UserProfile::find($request->profile->id)) {

            $user = User::find($this->user_id);
            $user = $this->beautify->userOBJ($user);

            $data['user'] = $user;
            $data['profile'] = $profile;
            return response()->json($this->structure(true, 'Success', $data), 200);
        }

        return response()->json($this->structure(false, 'Profile not found'), 200);
    }

    public function update_profile_icon(Request $request)
    {
        $error_msg = ['image.max' => 'Image may not be greater than 2 MB.'];
        $validator = Validator::make($request->all(), [
            'image' => 'required|file|mimes:gif,jpg,bmp,png,jpeg,pjpeg|max:2048',

        ],$error_msg);
        if ($validator->fails()) {
             return response()->json($this->structure(false, $validator->errors()->first()), 200);
        } 

        if ($user_profile = UserProfile::find($request->profile->id)) {
            if ($request->file('image') != "") {

                $file = $request->file('image');
                $temp_name = $_FILES["image"]["tmp_name"];
                $ext = preg_replace('/^.*\.([^.]+)$/D', '$1', $file->getClientOriginalName());
                $file_name = date('ymdhis').'_'.strtoupper(str_replace(' ', '_', $user_profile->name)).".$ext";
                $targetDir = TargetPath::user_profile_icon();
                if (!(File::isDirectory($targetDir))) {

                    File::makeDirectory($targetDir, 0777, true, true);
                }
                $file->move($targetDir, $file_name);

                $user_profile->icon = $file_name;
            }
            if ($user_profile->save()) {
                $data['profile_icon'] = DisplayPath::user_profile_icon($user_profile->icon);
                return response()->json($this->structure(true, 'Profile icon updated successfully.', $data), 200);
            }
        }
        return response()->json($this->structure(false, 'Profile not found!'), 200);
    }

    public function update_current_location(Request $request)
    {
        $validator = Validator::make($request->all(), [
              'location' => 'required',
              'longitude' => 'required',
              'latitude' => 'required'
        ]);
        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }
        
        if ($user_profile = UserProfile::find($request->profile->id)) {

            if ($request->location){

                $data['location'] = $request->location;
                $data['longitude'] = $request->longitude;
                $data['latitude'] = $request->latitude;

                $user_profile->location = $data;
            }

            if ($user_profile->save()) {
                return response()->json($this->structure(true, "Location Updated successfully.", [ $user_profile->location, true ]), 200);
            }
            return response()->json($this->structure(false, 'Something went wrong!'), 200);
        }

        return response()->json($this->structure(false, 'Profile not found!'), 200);
    }

    public function delete(Request $request)
    {
        if ($profile = UserProfile::find($request->profile->id)) {
            
            if ($profile->type == 'Self' || $profile->user_id) {
                return response()->json($this->structure(true, 'You can only delete the add-on profiles!'), 200);
            }

            try {

                $profile->delete();

                //delete all the shared files by this user.
                Share::where('profile_id', $profile->id)->delete();

                //token distory
                $token = auth('api')->invalidate(true);

                //generate new token.
                $user = User::find($this->user_id);
                $token = auth('api')->claims(['logged_in_profile' => []])->login($user);
                return response()->json($this->token_structure(true, 'Profile Deleted!', [], $token), 200);
            } catch (\Exception $e) {
                return response()->json($this->structure(false, 'Profile not found!'), 200);
            }
        }
        return response()->json($this->structure(false, 'Profile not found'), 200);
    }

}
