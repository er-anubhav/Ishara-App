<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Library\Structure;
use Illuminate\Http\Request;
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

        $data = Admin::where('role', 'subadmin')->orderBy('id', 'desc')->get();

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

                if ($specialization) {
                    return implode(', ', $specialization);
                }
            }
            return '-';
        })->addColumn('contact', function ($data) {
            return '<span>'.$data->email.'</span><br><span>'.$data->phone.'</span>';
        })->setRowClass(function ($user) {
                    return 'sub-admin-edit-btn';
        })->setRowAttr([
            'style' => 'cursor:pointer;',
            'data-value' => '{{$id}}|{{$name}}|{{$email}}|{{$phone}}|{{$specializations}}',
        ])->rawColumns(['action', 'contact', 'status', 'specializations'])->make(true);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
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
              'email' => 'required|email',  
              'phone' => 'required|numeric',  
              'password' => 'required|min:6',  
              'confirm_password' => 'required|same:password',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $data = [
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'role' => 'subadmin',
                'password' => bcrypt($request->password),
                'specializations' => json_encode($request->specializations, true),
                'created_at' => date('Y-m-d h:i:s'),
            ];

        if (Admin::create($data)) {
            return response()->json($this->structure(true, 'Sub Admin Added Successfully!'), 200);
        }

        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Admin  $admin
     * @return \Illuminate\Http\Response
     */
    public function show(Admin $admin)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Admin  $admin
     * @return \Illuminate\Http\Response
     */
    public function edit(Admin $admin)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Admin  $admin
     * @return \Illuminate\Http\Response
     */
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

        $data = [
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'role' => 'subadmin',
                'specializations' => json_encode($request->specializations, true),
                'updated_at' => date('Y-m-d h:i:s'),
            ];

        if (Admin::where('id', $request->sub_admin_id)->update($data)) {
            return response()->json($this->structure(true, 'Sub Admin Updated Successfully!'), 200);
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
}
