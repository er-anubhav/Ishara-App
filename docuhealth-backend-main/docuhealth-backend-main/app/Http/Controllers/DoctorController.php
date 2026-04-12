<?php

namespace App\Http\Controllers;

use App\Models\Doctor;
use App\Models\DoctorAddress;
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
        $data['specializations'] = Specialization::get();
        $data['degree'] = [];
        $data['services'] = [];

        $doctors = Doctor::select('degree', 'services')->get();
        foreach ($doctors as $doctor) {
            
            $degree = $doctor->degree;
            if (is_array($degree)) {
                $data['degree'] = array_merge($data['degree'], $degree);
            }

            $services = $doctor->services;
            if (is_array($services)) {
                $data['services'] = array_merge($data['services'], $services);
            }
        }
        return view('doctor.index', $data);
    }

    /**
     * Display a table listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function data(Request $request){

        $query = Doctor::orderBy('id', 'desc');

        //If request have filters.
        if ($filters = $request->filters) {

            if ($filters['role'] && $filters['role'] != 'All') {
                $query->where("role", $filters['role']);
            }

            if ($filters['featured'] && $filters['featured'] != 'All') {
                $query->where("featured", $filters['featured']);
            }

            if ($filters['verified'] && $filters['verified'] != 'All') {
                $query->where("verified", $filters['verified']);
            }

            if ($filters['status'] && $filters['status'] != 'All') {
                $query->where("is_active", $filters['status']);
            }

            // //Work Experiance From
            if (!empty($filters['work_experience_start_year'])) {

                $start_year = $filters['work_experience_start_year'];
                if ($start_year && $start_year != 'All' && $start_year != 0) {
                    $query->where("experience_years", ">=", $start_year);
                }
            }
            if (!empty($filters['work_experience_start_month'])) {

                $start_month = $filters['work_experience_start_month'];
                if ($start_month && $start_month != 'All' && $start_month != 0) {
                    $query->where("experience_months", ">=", $start_month);
                }
            }

            // //Work Experiance To
            if (!empty($filters['work_experience_end_year'])) {

                $end_year = $filters['work_experience_end_year'];
                if ($end_year && $end_year != 'All' && $end_year != 0) {
                    $query->where("experience_years", "<=", $end_year);
                }
            }
            if (!empty($filters['work_experience_end_month'])) {

                $end_month = $filters['work_experience_end_month'];
                if ($end_month && $end_month != 'All' && $end_month != 0) {
                    $query->where("experience_months", "<=", $end_month);
                }
            }

            if ($filters['specializations'] && $filters['specializations'] != 'All') {
                $specializations = is_array($filters['specializations']) ? implode(',', $filters['specializations']) : '';
                $query = $query->whereRaw('json_contains(specializations, \'["'.$specializations.'"]\')');
            }
            
            if ($filters['degrees'] && $filters['degrees'] != 'All') {

                $degree = is_array($filters['degrees']) ? implode(',', $filters['degrees']) : '';
                $query = $query->whereRaw('json_contains(degree, \'["'.$degree.'"]\')');
            }

            if ($filters['service'] && $filters['service'] != 'All') {
                $service = is_array($filters['service']) ? implode(',', $filters['service']) : '';
                $query = $query->whereRaw('json_contains(services, \'["'.$service.'"]\')');
            }

            if (!in_array($request->filters['joining_date_range'], [null, '', 'All', 'Any'])) {
                $date_range = explode('-', $request->filters['joining_date_range']);
                $date_form = preg_replace('/\s+/', '', $date_range[0]);
                $date_to = preg_replace('/\s+/', '', $date_range[1]);

                $data = $data->where('created_at', '>=', date('Y-m-d', strtotime($date_form)))
                                ->where('created_at', '<=', date('Y-m-d', strtotime($date_to)));
            }

            if (!in_array($request->filters['joining_date_range'], [null, '', 'All', 'Any'])) {
                $date_range = explode('-', $request->filters['joining_date_range']);
                $date_form = preg_replace('/\s+/', '', $date_range[0]);
                $date_to = preg_replace('/\s+/', '', $date_range[1]);

                $query = $query->where('created_at', '>=', date('Y-m-d', strtotime($date_form)))
                                ->where('created_at', '<=', date('Y-m-d', strtotime($date_to)));
            }
        }

        $data = $query->orderBy('id', 'desc')->get();
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
            if ($data->experience_years || $data->experience_months) {

                $experience = '0';
                if ($data->experience_years) {
                    $experience = $data->experience_years;
                }

                if ($data->experience_months) {
                    $experience .= '.'.$data->experience_years;
                }
                return $experience.' Year';
            }
            return '<span class="text-danger">No experience!</span>';
        })->addColumn('specializations', function ($data) {
            if ($data->specializations) {
                $specialization = Specialization::whereIn('id', $data->specializations)->pluck('name')->toArray();
                return implode(', ', $specialization);
            }
            return '-';
        })->addColumn('services', function ($data) {
            if ($data->services) {
                return is_array($data->services) ? implode(', ', $data->services) : '-' ;
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
              // 'time_from' => 'required',  
              // 'time_to' => 'required',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $data = [
                'name' => $request->name,
                'specializations' => $request->specializations,
                'experience_years' => $request->experience_years,
                'experience_months' => $request->experience_months,
                'degree' => $request->degrees,
                'services' => $request->services,
                'description' => $request->description,
                'verified' => $request->verified,
                'featured' => $request->featured,
                'created_at' => date('Y-m-d h:i:s'),
            ];

        if ($doctor = Doctor::create($data)) {

            $total_address = is_array($request->location) ? sizeof($request->location) : 0 ;
            for ($i=0; $i < $total_address; $i++) { 
                
                if (isset($request->latitude[$i]) && isset($request->longitude[$i])) {

                    DoctorAddress::create([
                                        'belongs_to' => $doctor->id,
                                        'name' => $request->hospital_name[$i],
                                        'time_from' => $request->time_from[$i],
                                        'time_to' => $request->time_to[$i],
                                        'open_days' => strtolower($request->open_days[$i]),
                                        'latitude' => $request->latitude[$i],
                                        'longitude' => $request->longitude[$i],
                                        'addr1' => $request->location[$i],
                                    ]);
                }
            }
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

        $doctor->address;
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
              // 'time_from' => 'required',  
              // 'time_to' => 'required',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $data = [
                'name' => $request->name,
                'specializations' => $request->specializations,
                'experience_years' => $request->experience_years,
                'experience_months' => $request->experience_months,
                'degree' => $request->degrees,
                'services' => $request->services,
                'description' => $request->description,
                'verified' => $request->verified,
                'featured' => $request->featured,
                'updated_at' => date('Y-m-d h:i:s'),
            ];

        if (Doctor::where('id', $request->doctor_id)->update($data)) {

            DoctorAddress::where('belongs_to', $request->doctor_id)->delete();
            $total_address = is_array($request->location) ? sizeof($request->location) : 0 ;
            for ($i=0; $i < $total_address; $i++) { 
                
                if (isset($request->latitude[$i]) && isset($request->longitude[$i])) {

                    DoctorAddress::create([
                                        'belongs_to' => $request->doctor_id,
                                        'name' => $request->hospital_name[$i],
                                        'time_from' => $request->time_from[$i],
                                        'time_to' => $request->time_to[$i],
                                        'open_days' => strtolower($request->open_days[$i]),
                                        'latitude' => $request->latitude[$i],
                                        'longitude' => $request->longitude[$i],
                                        'addr1' => $request->location[$i],
                                    ]);
                }
            }

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
                $specialization = Specialization::whereIn('id', $data->specializations)->pluck('name')->toArray();
                return implode(', ', $specialization);
            }
            return '-';
        })->addColumn('services', function ($data) {
            if ($data->services) {
                return is_array($data->services) ? implode(', ', $data->services) : '-' ;
            }
            return '-';
        })->addColumn('other', function ($data) {
            return '-';
        })->rawColumns(['action', 'experience', 'other', 'status', 'specializations', 'services'])->make(true);
    }
}
