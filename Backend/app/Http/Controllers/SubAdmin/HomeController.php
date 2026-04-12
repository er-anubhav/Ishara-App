<?php

namespace App\Http\Controllers\SubAdmin;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use App\Models\Admin;
use App\Models\Doctor;
use App\Models\Specialization;
use App\Library\Structure;
use Validator;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth:sub-admin');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        $doctors = [];
        $data = Doctor::where('featured', 'Yes')->inRandomOrder()->limit(5)->get();

        foreach ($data as $value) {
            
            $value->experience = 'No experience!';
            if ($value->specializations) {
                $specializations = $value->specializations;
                $specializations = Specialization::whereIn('id', $specializations)->pluck('name')->toArray();
                $value->specializations = implode(', ', $specializations);
            }

            if (!$value->specializations) {
                $value->specializations = '-';
            }

            if ($value->experience_years || $value->experience_months) {

                $value->experience = '0';
                if ($value->experience_years) {
                    $value->experience = $value->experience_years;
                }

                if ($value->experience_months) {
                    $value->experience  .= '.'.$value->experience_years;
                }
                $value->experience .= $value->experience > 1 ? ' Years' : 'Year' ;
            }
            array_push($doctors, $value);
        }
        return view('sub-admin.home', ['doctors' => $doctors]);
    }


    public function password_change(Request $request){
        
        $validator = Validator::make($request->all(), 
            [ 
              'current_password' => 'required|min:6',  
              'password' => 'required|min:6',  
              'confirm_password' => 'required|same:password|min:6',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        try {
            $admin = Admin::findOrFail(Auth::guard('admin')->user()->id);
        } catch (\Exception $e) {
            return response()->json($this->structure(false, 'Something went wrong!'), 200);
        }

        if (!(Hash::check($request->current_password, $admin->password))) {
            return response()->json($this->structure(false, 'Old password is not currect!'), 200);
        }

        $admin->password = Hash::make($request->password);
        $admin->updated_at = date('Y-m-d h:i:s');

        if ($admin->save()) {
            return response()->json($this->structure(true, 'Password has changed Successfully!'), 200);
        }
        return response()->json($this->structure(false, 'Something went wrong!'), 200);
    }
}
