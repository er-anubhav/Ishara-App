<?php

namespace App\Http\Controllers;

use App\Models\Doctor;
use App\Models\Specialization;
use App\Library\Structure;
use Illuminate\Http\Request;
use Validator;
use Redirect;

class DoctorController extends Controller
{
    use Structure;
    /**
     * Display a listing view of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('doctor.index');
    }

    /**
     * Display a table listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function data(Request $request){

        $data = Doctor::orderBy('id', 'desc')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {
            $url = url('/admin/doctors').'/'.$data->id.'/edit';
            $button = '<div class="btn-group"><a href="'.$url.'" target="_BLANK" class="edit-btn btn btn-sm btn-secondary"><i class="bx bx-edit"></i></a>';

            if ($data->is_active == 'Yes') {
                $button .= '<a href="javascript:void()" name="disable" data-value="'.$data->id.'" class="status-btn btn btn-sm btn-danger"><i class="bx bx-block"></i></a>';
            }else{
                $button .= '<a href="javascript:void()" name="enable" data-value="'.$data->id.'" class="status-btn btn btn-sm btn-success"><i class="bx bx-check"></i></a>';
            }

            $button .= '</div>';
            return $button;
        })->addColumn('status', function ($data) {
            if ($data->is_active == 'Yes') {
                return '<span class="badge badge-light-info">Active</span>';
            }
            return '<span class="badge badge-light-danger">In-Active</span>';
        })->addColumn('experience', function ($data) {
            if ($data->experience_years && $data->experience_months) {
                return $data->experience_years.' Year '.$data->experience_months.' Month';
            }
            return '<span class="text-danger">No experience!</span>';
        })->addColumn('specializations', function ($data) {
            if ($data->specializations) {
                $specialization = json_decode($data->specializations, true);
                return implode(', ', $specialization);
            }
            return '-';
        })->addColumn('services', function ($data) {
            if ($data->services) {
                $services = json_decode($data->services, true);
                return implode(', ', $services);
            }
            return '-';
        })->addColumn('other', function ($data) {
            return '-';
        })->rawColumns(['action', 'experience', 'other', 'status', 'specializations', 'services'])->make(true);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        $data['specializations'] = Specialization::all();
        return view('doctor.create', $data);
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
              'specializations' => 'required',  
              'verified' => 'required',  
              'featured' => 'required',  
              'experience_years' => 'required',  
              'experience_months' => 'required',  
              'time_form' => 'required',  
              'time_to' => 'required',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $data = [
                'name' => $request->name,
                'specializations' => json_encode($request->specializations, true),
                'clinic_address' => json_encode($request->address, true),
                'experience_years' => $request->experience_years,
                'experience_months' => $request->experience_months,
                'time_from' => $request->time_from,
                'time_to' => $request->time_to,
                'degree' => json_encode($request->degrees, true),
                'services' => json_encode($request->services, true),
                'description' => $request->description,
                'verified' => $request->verified,
                'featured' => $request->featured,
                'created_at' => date('Y-m-d h:i:s'),
            ];

        if (Doctor::create($data)) {
            return response()->json($this->structure(true, 'Doctor Added Successfully!'), 200);
        }

        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Doctor  $doctor
     * @return \Illuminate\Http\Response
     */
    public function show(Request $request)
    {
        $doctor = Doctor::find($request->doctor);

        return response()->json($this->structure(true, "", $doctor), 200);
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Doctor  $doctor
     * @return \Illuminate\Http\Response
     */
    public function edit(Request $request)
    {
        $doctor = Doctor::find($request->doctor);

        if ($doctor) {
            $data['specializations'] = Specialization::all();
            $data['doctor'] = $doctor;
            $data['doctor_id'] = $doctor->id;
            return view('doctor.edit', $data);
        }
        
        return Redirect::route('doctors.index');
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Doctor  $doctor
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Doctor $doctor)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required',  
              'specializations' => 'required',  
              'verified' => 'required',  
              'featured' => 'required',  
              'experience_years' => 'required',  
              'experience_months' => 'required',  
              'time_form' => 'required',  
              'time_to' => 'required',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $data = [
                'name' => $request->name,
                'specializations' => json_encode($request->specializations, true),
                'clinic_address' => json_encode($request->address, true),
                'experience_years' => $request->experience_years,
                'experience_months' => $request->experience_months,
                'time_from' => $request->time_from,
                'time_to' => $request->time_to,
                'degree' => json_encode($request->degrees, true),
                'services' => json_encode($request->services, true),
                'description' => $request->description,
                'verified' => $request->verified,
                'featured' => $request->featured,
                'updated_at' => date('Y-m-d h:i:s'),
            ];

        if (Doctor::where('id', $request->doctor_id)->update($data)) {
            return response()->json($this->structure(true, 'Doctor Updated Successfully!'), 200);
        }

        return response()->json($this->structure(false, "No Changes!"), 200);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Doctor  $doctor
     * @return \Illuminate\Http\Response
     */
    public function destroy(Doctor $doctor)
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
        $response = Doctor::where('id', $request->id)->update($data);

        if ($response > 0) {
            if ($request->status == 'delete') {
              return response()->json(['error' => false, 'message' => 'Deleted Succesfully!']);
            }
            return response()->json(['error' => false, 'message' =>'Status Updated Succesfully!']);
        }
        return response()->json(['error'=> true, 'message' => 'Somthing went wrong, try again !']);
    }
    

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Doctor  $doctor
     * @return \Illuminate\Http\Response
     */
    public function featured(Request $request)
    {
        return view('doctor.featured');
    }

    public function featured_data(Request $request){

        $data = Doctor::where('featured', 'Yes')->orderBy('id', 'desc')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {
            $url = url('/admin/doctors').'/'.$data->id.'/edit';
            $button = '<div class="btn-group"><a href="'.$url.'" target="_BLANK" class="edit-btn btn btn-sm btn-secondary"><i class="bx bx-edit"></i></a>';

            if ($data->is_active == 'Yes') {
                $button .= '<a href="javascript:void()" name="disable" data-value="'.$data->id.'" class="status-btn btn btn-sm btn-danger"><i class="bx bx-block"></i></a>';
            }else{
                $button .= '<a href="javascript:void()" name="enable" data-value="'.$data->id.'" class="status-btn btn btn-sm btn-success"><i class="bx bx-check"></i></a>';
            }

            $button .= '</div>';
            return $button;
        })->addColumn('status', function ($data) {
            if ($data->is_active == 'Yes') {
                return '<span class="badge badge-light-info">Active</span>';
            }
            return '<span class="badge badge-light-danger">In-Active</span>';
        })->addColumn('experience', function ($data) {
            if ($data->experience_years && $data->experience_months) {
                return $data->experience_years.' Year '.$data->experience_months.' Month';
            }
            return '<span class="text-danger">No experience!</span>';
        })->addColumn('specializations', function ($data) {
            if ($data->specializations) {
                $specialization = json_decode($data->specializations, true);
                return implode(', ', $specialization);
            }
            return '-';
        })->addColumn('services', function ($data) {
            if ($data->services) {
                $services = json_decode($data->services, true);
                return implode(', ', $services);
            }
            return '-';
        })->addColumn('other', function ($data) {
            return '-';
        })->rawColumns(['action', 'experience', 'other', 'status', 'specializations', 'services'])->make(true);
    }
}
