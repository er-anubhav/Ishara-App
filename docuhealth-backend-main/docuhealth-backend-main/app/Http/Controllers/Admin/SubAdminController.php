<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Library\Structure;
use Illuminate\Http\Request;
use App\Models\Specialization;
use Validator;

class SubAdminController extends Controller
{
    use Structure;
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('sub-admin');
    }

    /**
     * Display a table listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function data(Request $request){

        $data = Admin::where('role', 'Sub-Admin')->orderBy('id', 'desc')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {

            if ($data->is_active == 'Yes') {
                $button = '<a href="javascript:void()" name="disable" data-value="'.$data->id.'" class="status-btn btn btn-sm btn-danger"><i class="bx bx-block"></i></a>';
            }else{
                $button = '<a href="javascript:void()" name="enable" data-value="'.$data->id.'" class="status-btn btn btn-sm btn-success"><i class="bx bx-check"></i></a>';
            }

            return $button;
        })->addColumn('status', function ($data) {
            if ($data->is_active == 'Yes') {
                return '<span class="badge badge-light-info">Active</span>';
            }
            return '<span class="badge badge-light-danger">In-Active</span>';
        })->addColumn('specializations', function ($data) {
            if ($data->specializations) {
                $specialization = json_decode($data->specializations, true);
                if (is_array($specialization)) {
                    $specialization = Specialization::whereIn('id', $specialization)->pluck('name')->toArray();
                    return implode(', ', $specialization);
                }
            }
            return '-';
        })->addColumn('contact', function ($data) { 
            $contact = '-';
            if ($data->phone) {
                $contact = '<span style="display:block;" class="subadmin-contact"><i class="bx bxs-phone-call" style="position: relative;top: 3px;left: -5px;"></i><a href="tel:'.$data->phone.'" style="color:#0a187c;">'.$data->phone.'</a></span>';
            }
            if ($data->email) {
                 $contact .= '<span style="display:block;" class="subadmin-contact"><i class="bx bx-envelope" style="position: relative;top: 3px;left: -5px;"></i><a href="mailto:'.$data->email.'" style="color:#0a187c;">'.$data->email.'</a></span>';
            }
            return $contact;
        })->setRowClass(function ($user) {
                    return 'sub-admin-edit-btn';
        })->setRowAttr([
            'style' => 'cursor:pointer;',
            'data-value' => '{{$id}}|{{$name}}|{{$email}}|{{$phone}}|{{$specializations}}',
        ])->rawColumns(['action', 'contact', 'status', 'specializations'])->make(true);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required',  
              'email' => 'required|email|unique:admins',  
              'phone' => 'required|numeric|unique:admins',  
              'password' => 'required|min:6',  
              'confirm_password' => 'required|same:password',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $data = [
                'name' => ucwords($request->name),
                'email' => strtolower($request->email),
                'phone' => $request->phone,
                'role' => 'Sub-Admin',
                'password' => bcrypt($request->password),
                'specializations' => json_encode($request->specializations, true),
                'created_at' => date('Y-m-d h:i:s'),
            ];

        if (Admin::create($data)) {
            return response()->json($this->structure(true, 'Sub Admin Added Successfully!'), 200);
        }

        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    public function update(Request $request, Admin $admin)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required',  
              'email' => 'required|email',  
              'phone' => 'required|numeric',
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        if ($admin = Admin::find($request->sub_admin_id)) {

            if (Admin::where('id', '!=', $admin->id)->where('email', $request->email)->count()) {
                return response()->json($this->structure(false, "Email is already exist!"), 200);
            }
            if (Admin::where('id', '!=', $admin->id)->where('phone', $request->email)->count()) {
                return response()->json($this->structure(false, "Phone is already exist!"), 200);
            }

            $admin->name = ucwords($request->name);
            $admin->email = strtolower($request->email);
            $admin->phone = $request->phone;
            $admin->role = 'Sub-Admin';
            $admin->specializations = json_encode($request->specializations, true);
            $admin->updated_at = date('Y-m-d h:i:s');

            if ($request->password) {
                
                if ($request->password != $request->confirm_password) {
                    return response()->json($this->structure(false, "Passwword & confirm password must be match!"), 200);
                }
                $request->password = bcrypt($request->password);
            }

            if ($admin->save()) {
                return response()->json($this->structure(true, 'Sub Admin Updated Successfully!'), 200);
            }
        }
        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Admin  $admin
     * @return \Illuminate\Http\Response
     */
    public function destroy(Admin $admin)
    {
        //
    }

    public function status(Request $request){

        if ($request->status == 'delete') {
           $data = ['deleted_at' => date('Y-m-d H:i:s')];
        } else {
          if ($request->status == 'enable') {
            $data = ['is_active'=>'Yes', 'updated_at' => date('Y-m-d H:i:s')];
          }
          else{
             $data = ['is_active'=>'No', 'updated_at' => date('Y-m-d H:i:s')];
          }
        }
        $response = Admin::where('id', $request->id)->where('role', 'Sub-Admin')->update($data);

        if ($response > 0) {
            if ($request->status == 'delete') {
              return response()->json(['error' => false, 'message' => 'Deleted Succesfully!']);
            }
            return response()->json(['error' => false, 'message' =>'Status Updated Succesfully!']);
        }
        return response()->json(['error'=> true, 'message' => 'Somthing went wrong, try again !']);
    }
}
