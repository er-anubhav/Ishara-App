<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Library\Structure;
use App\Library\Beautify;
use App\Models\Doctor;
use App\Models\DoctorAddress;
use App\Models\UserProfile;
use App\Models\Specialization;
use App\Models\Folder;
use App\Models\File as FileModal;
use DB;
use Illuminate\Support\Facades\Schema;
 
class MedicoSearchController extends Controller
{
    // Structure of response API.
    use Structure;

    public function search(Request $request){

        //Search filters
        $name = $request->name;
        $role = $request->near_by;
        $category = $request->category;
        $distance = $request->distance;
        $experience = $request->experience;
        $verified = $request->verified;
        $degree = $request->degree;
        $service = $request->service;

        $profile_id = isset($request->profile->id) ? $request->profile->id : 0 ;
        $profile = UserProfile::find($profile_id);

        //get profile latitude & longitude.
        $location = isset($profile->location) ? json_decode($profile->location, true) : null ;
        $latitude = isset($location['latitude']) ? $location['latitude'] : null ;
        $longitude = isset($location['longitude']) ? $location['longitude'] : null ;

        $table = Doctor::where('doctors.is_active', 'Yes');
        $hasRoleColumn = Schema::hasColumn('doctors', 'role');

        //filters
        if (($distance && $distance !== 'All') && ($latitude && $longitude)) {

            $oprator__1 = '<=';
            $oprator__2 = '>=';
            //default 5 KM redius.
            $distance__1 = 5; 
            $distance__2 = 5;
            $distance_value = explode('-', $distance);
            $near_by_doctor_ids = [];

            if (sizeof($distance_value) == 2) {
                
                /*
                -ls = less than, gt = greater than, where 'ls' will be always in 0th index & 'gt' is always on index 1.
                -Reference to filter API.
                */
                if ($distance_value[0] == 'ls') { 
                    $distance__1 = intval($distance_value[1]);
                }
                elseif($distance_value[1] == 'gt'){
                    $oprator__1 = '>=';
                    $distance__1 = intval($distance_value[0]);
                }else{
                    $oprator__1 = '>=';
                    $oprator__2 = '<=';
                    $distance__1 = intval($distance_value[0]);
                    $distance__2 = intval($distance_value[1]);
                }

            }else{
                $distance__1 = intval($distance_value);
            }
            
            $table2 = DoctorAddress::whereRaw("(6371 * acos( cos( radians('$latitude') ) * cos( radians(latitude) ) * cos( radians(longitude) - radians('$longitude') ) + sin( radians('$latitude') ) * sin( radians(latitude) ) ) ) $oprator__1 $distance__1");

            if (sizeof($distance_value) == 2) {
                $table2 = $table2->whereRaw("(6371 * acos( cos( radians('$latitude') ) * cos( radians(latitude) ) * cos( radians(longitude) - radians('$longitude') ) + sin( radians('$latitude') ) * sin( radians(latitude) ) ) ) $oprator__2 $distance__2");
            }

            $table2 = $table2->select(DB::Raw("(6371 * acos( cos( radians('$latitude') ) * cos( radians(latitude) ) * cos( radians(longitude) - radians('$longitude') ) + sin( radians('$latitude') ) * sin( radians(latitude) ) ) ) AS distance"), 'belongs_to')->orderBy('distance', 'asc')->get();

            foreach ($table2 as $value) {
                if (!in_array($value->belongs_to, $near_by_doctor_ids)) {
                    array_push($near_by_doctor_ids, $value->belongs_to);
                }
            }

            $table = $table->whereIn('id', $near_by_doctor_ids);
        }

        if ($name && $name !== 'All') {
            $table = $table->where('doctors.name', 'like', '%' . $name . '%');
        }

        if ($role && $role !== 'All' && $hasRoleColumn) {
            $table = $table->where('doctors.role', $role);
        }

        if ($category && $category !== 'All') {
            $table = $table->whereRaw('json_contains(specializations, \'["'.$category.'"]\')');
        }

        if ($verified && $verified !== 'All') {
            $table = $table->where('doctors.verified', $verified);
        }

        if ($degree && $degree !== 'All') {
            $table = $table->whereRaw('json_contains(degree, \'["'.$degree.'"]\')');
        }

        if ($service && $service !== 'All') {
            $table = $table->whereRaw('json_contains(services, \'["'.$service.'"]\')');
        }

        if ($experience && $experience !== 'All') {
 
            $experience_value = explode('-', $experience);

            if (sizeof($experience_value) == 2) {
                
                /*
                -ls = less than, gt = greater than, where 'ls' will be always in 0th index & 'gt' is always on index 1.
                -Reference to filter API.
                */
                if ($experience_value[0] == 'ls') {
                    $experience = intval($experience_value[1]);
                    $table = $table->where('experience_years', '<=', $experience);
                }
                elseif($experience_value[1] == 'gt'){
                    $experience = intval($experience_value[0]);
                    $table = $table->where('experience_years', '>=', $experience);
                }else{
                    $experience__0 = intval($experience_value[0]);
                    $experience__1 = intval($experience_value[1]);
                    $table = $table->where('experience_years', '>=', $experience__0);
                    $table = $table->where('experience_years', '<=', $experience__1);
                }
            }
        }

        //Page Calculations.
        $data_records['pagination'] = true;
        $data_records['page'] = request('page') ? intval(request('page')) : 1 ;
        $data_records['limit'] = request('limit') ? request('limit') : 6 ;
        $data_records['start'] = $data_records['page'] == 1 ? 0 : ($data_records['page'] -1 ) * $data_records['limit'] ;

        //count the total lead data.
        $data_records['total_records'] = $table->count();

        $doctors = $table->skip($data_records['start'])->take($data_records['limit'])
                    ->select('doctors.*')
                    ->orderBy('id', 'desc')
                    ->get();

        $beautify = new Beautify();
        $doctors = $beautify->doctors($doctors);

        $data['data'] = $doctors;
        $data['data_records'] = $data_records;
        return response()->json($this->structure(true, "Serach Result", $data), 200);
    }

    public function featured(Request $request){

        //Search filters
        $name = $request->name;
        $role = $request->near_by;
        $category = $request->category;
        $distance = $request->distance;
        $experience = $request->experience;
        $verified = $request->verified;
        $degree = $request->degree;
        $service = $request->service;

        $profile_id = isset($request->profile->id) ? $request->profile->id : 0 ;
        $profile = UserProfile::find($profile_id);

        //get profile latitude & longitude.
        $location = isset($profile->location) ? json_decode($profile->location, true) : null ;
        $latitude = isset($location['latitude']) ? $location['latitude'] : null ;
        $longitude = isset($location['longitude']) ? $location['longitude'] : null ;

        $table = Doctor::where('doctors.is_active', 'Yes')->where('doctors.featured', 'Yes');
        if (Schema::hasColumn('doctors', 'role')) {
            $table = $table->where('doctors.role', 'Doctor');
        }

        //filters
        if (($distance && $distance !== 'All') && ($latitude && $longitude)) {

            $oprator__1 = '<=';
            $oprator__2 = '>=';
            //default 5 KM redius.
            $distance__1 = 5; 
            $distance__2 = 5;
            $distance_value = explode('-', $distance);
            $near_by_doctor_ids = [];

            if (sizeof($distance_value) == 2) {
                
                /*
                -ls = less than, gt = greater than, where 'ls' will be always in 0th index & 'gt' is always on index 1.
                -Reference to filter API.
                */
                if ($distance_value[0] == 'ls') { 
                    $distance__1 = intval($distance_value[1]);
                }
                elseif($distance_value[1] == 'gt'){
                    $oprator__1 = '>=';
                    $distance__1 = intval($distance_value[0]);
                }else{
                    $oprator__1 = '>=';
                    $oprator__2 = '<=';
                    $distance__1 = intval($distance_value[0]);
                    $distance__2 = intval($distance_value[1]);
                }

            }else{
                $distance__1 = intval($distance_value);
            }
            
            $table2 = DoctorAddress::whereRaw("(6371 * acos( cos( radians('$latitude') ) * cos( radians(latitude) ) * cos( radians(longitude) - radians('$longitude') ) + sin( radians('$latitude') ) * sin( radians(latitude) ) ) ) $oprator__1 $distance__1");

            if (sizeof($distance_value) == 2) {
                $table2 = $table2->whereRaw("(6371 * acos( cos( radians('$latitude') ) * cos( radians(latitude) ) * cos( radians(longitude) - radians('$longitude') ) + sin( radians('$latitude') ) * sin( radians(latitude) ) ) ) $oprator__2 $distance__2");
            }

            $table2 = $table2->select(DB::Raw("(6371 * acos( cos( radians('$latitude') ) * cos( radians(latitude) ) * cos( radians(longitude) - radians('$longitude') ) + sin( radians('$latitude') ) * sin( radians(latitude) ) ) ) AS distance"), 'belongs_to')->orderBy('distance', 'asc')->get();

            foreach ($table2 as $value) {
                if (!in_array($value->belongs_to, $near_by_doctor_ids)) {
                    array_push($near_by_doctor_ids, $value->belongs_to);
                }
            }

            $table = $table->whereIn('id', $near_by_doctor_ids);
        }

        $doctors = $table->limit(10)
                    ->select('doctors.*')
                    ->inRandomOrder()
                    ->get();

        $beautify = new Beautify();
        $doctors = $beautify->doctors($doctors);

        return response()->json($this->structure(true, "Featured Doctors", $doctors), 200);
    }

    public function search_details(Request $request){

        //Search filters
        $id = $request->id;

        $doctor = Doctor::where('id', $id)->with('address')->get();

        if ($doctor) {
            $beautify = new Beautify();
            $doctor = $beautify->doctors($doctor, 'Full');
            return response()->json($this->structure(true, "Serach Found", $doctor), 200);
        }
        return response()->json($this->structure(true, "Serach Not Found", $doctor), 200);
    }

} //Class End Tag.
