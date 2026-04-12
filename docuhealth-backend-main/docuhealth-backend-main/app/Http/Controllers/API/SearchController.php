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
use App\Models\Post;
use App\Models\File as FileModal;
use DB;

class SearchController extends Controller
{
    // Structure of response API.
    use Structure;

    public function search(Request $request){

        $data = [];

        //Search filters
        $name = $request->name;

        $profile_id = isset($request->profile->id) ? $request->profile->id : 0 ;
        $profile = UserProfile::find($profile_id);

        //get profile latitude & longitude.
        $distance = 10;
        $location = isset($profile->location) ? json_decode($profile->location, true) : null ;
        $latitude = isset($location['latitude']) ? $location['latitude'] : null ;
        $longitude = isset($location['longitude']) ? $location['longitude'] : null ;

        $doctors = Doctor::where('doctors.is_active', 'Yes');

        //filters
        if ($latitude && $longitude) {

            $near_by_doctor_ids = [];
            $table2 = DoctorAddress::whereRaw("(6371 * acos( cos( radians('$latitude') ) * cos( radians(latitude) ) * cos( radians(longitude) - radians('$longitude') ) + sin( radians('$latitude') ) * sin( radians(latitude) ) ) ) <= $distance")

                    ->select(DB::Raw("(6371 * acos( cos( radians('$latitude') ) * cos( radians(latitude) ) * cos( radians(longitude) - radians('$longitude') ) + sin( radians('$latitude') ) * sin( radians(latitude) ) ) ) AS distance"), 'belongs_to')->orderBy('distance', 'asc')->get();

            foreach ($table2 as $value) {
                if (!in_array($value->belongs_to, $near_by_doctor_ids)) {
                    array_push($near_by_doctor_ids, $value->belongs_to);
                }
            }

            $doctors = $doctors->whereIn('id', $near_by_doctor_ids);
        }
        $doctors = $doctors->where('doctors.name', 'like', '%' . $name . '%')->limit(3) 
                        ->addSelect('id', 'name', 'role as tag', 'specializations', 'experience_years', 'experience_months')->inRandomOrder()->get();

        //Folders search
        $folders = Folder::where('profile_id', $profile_id)->where('name', 'like', '%' . $request->name . '%')->inRandomOrder()->limit(3)
                                    ->addSelect('id', 'name', 'belongs_to as category', 'created_at', DB::raw("'folder' as tag"))->get()->toArray();

        //File Search.
        $files = FileModal::where('profile_id', $profile_id)->where('name', 'like', '%' . $request->name . '%')->inRandomOrder()->limit(3)
                                                    ->addSelect('id', 'name', 'category', 'file_type', 'created_at', DB::raw("'file' as tag"))->get();

        $posts = Post::leftJoin('categories as c', 'c.id', 'posts.category')->where('posts.heading', 'like', '%' . $request->name . '%')
                    ->orWhere('posts.description', 'like', '%' . $request->name . '%')->orWhereRaw('json_contains(posts.tags, \'["'.$request->name.'"]\')')
                    ->where('posts.status', 'Active')->inRandomOrder()->limit(3)
                    ->addSelect('posts.id', 'posts.heading', 'posts.description', 'posts.tags', 'posts.image', 'posts.created_at', 'c.name as category_name', DB::raw("'post' as tag"))->get();

        $beautify = new Beautify();
        $doctors = $beautify->search_medico($doctors);
        $files = $beautify->files($files, $profile_id, 'Bookmark');
        $posts = $beautify->blogs($posts);

        $data = array_merge($data, array_merge(array_merge($files, $folders), array_merge($doctors, $posts)));
        return response()->json($this->structure(true, "Serach Result", $data), 200);
    }

    public function files_and_folders(Request $request)
    {
        $profile_id = isset($request->profile->id) ? $request->profile->id : 0 ;
        if($profile_id){

            //Folders search
            $folders = Folder::where('profile_id', $profile_id);

            //Filters
            if ($request->category) {
                $folders = $folders->where('belongs_to', $request->category);
            }
            if ($request->name) {
                $folders = $folders->where('name', 'like', '%' . $request->name . '%');
            }
            
            //File Search.
            $files = FileModal::where('profile_id', $profile_id);

            //Filters
            if ($request->category) {
                $files = $files->where('category', $request->category);
            }
            if ($request->name) {
                $files = $files->where('name', 'like', '%' . $request->name . '%');
            }

            $folders = $folders->inRandomOrder()->limit(5)->addSelect('id', 'name', 'belongs_to as category', 'created_at', DB::raw("'folder' as tag"))->get()->toArray();
            $files = $files->inRandomOrder()->limit(5)->addSelect('id', 'name', 'category', 'file_type', 'created_at', DB::raw("'file' as tag"))->get();

            $data = [];
            $beautify = new Beautify();
            $files = $beautify->files($files, $profile_id, 'Bookmark');

            $data = array_merge($folders, $files);

            if (!empty($data)) {
                return response()->json($this->structure(true, 'Search Result', $data), 200);
            }
            return response()->json($this->structure(true, "Data not found!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function filters(Request $request){

        $filters = [];

        //Sort by.
        // $sort_by['name'] = 'Sort by';
        // $sort_by['filter_var'] = 'sort_by';
        // $sort_by['data'] = [['name'=>'Date','value'=>'date'], ['name'=>'Name', 'value'=>'name'], ['name'=>'Distance', 'value'=>'distance']];
        // array_push($filters, $sort_by);

        //Near by.
        $category['name'] = 'Near by';
        $category['filter_var'] = 'near_by';
        $category['data'] = [['name'=>'Doctors','value'=>'Doctor'], ['name'=>'Labs', 'value'=>'Lab'], ['name'=>'Hospitals', 'value'=>'Hospital']];
        array_push($filters, $category);

        //Distance.
        $distance['name'] = 'Distance';
        $distance['filter_var'] = 'distance';
        $distance['data'] = [['name'=>'Less than 5 KM','value'=>'ls-5'], ['name'=>'5 KM to 10 KM','value'=>'5-10'], ['name'=>'10 KM to 20 KM','value'=>'10-20'], ['name'=>'Above 20 KM','value'=>'20-gt']];
        array_push($filters, $distance);

        $services = $degrees = $services_temp = $degrees_temp = [];
        $doctors = Doctor::select('degree', 'services')->get();

        foreach ($doctors as $doctor) {
            
            $all_degrees = $doctor->degree;
            if (is_array($all_degrees)) {
                for ($i=0; $i < sizeof($all_degrees); $i++) { 
                    $degree = [];
                    $degree['name'] = ucfirst($all_degrees[$i]);
                    $degree['value'] = $all_degrees[$i];

                    if(!in_array($degree['name'], $degrees_temp)){
                        array_push($degrees, $degree);
                        array_push($degrees_temp, $degree['name']);
                    }    
                }
            }
            
            $all_services = $doctor->services;
            if (is_array($all_services)) {
                for ($i=0; $i < sizeof($all_services); $i++) {
                    $service = [];
                    $service['name'] = ucfirst($all_services[$i]);
                    $service['value'] = $all_services[$i];

                    if(!in_array($service['name'], $services_temp)){
                        array_push($services, $service);
                        array_push($services_temp, $service['name']);
                    }
                }
            }
        }

        //Service.
        $service_filter['name'] = 'Service';
        $service_filter['filter_var'] = 'service';
        $service_filter['data'] = $services;
        array_push($filters, $service_filter);

        //Degree.
        $degree_filter['name'] = 'Degree';
        $degree_filter['filter_var'] = 'degree';
        $degree_filter['data'] = $degrees;
        array_push($filters, $degree_filter);

        //Experience.
        $experience['name'] = 'Experience';
        $experience['filter_var'] = 'experience';
        $experience['data'] = [['name'=>'< 1 Year','value'=>'0-1'], ['name'=>'1-3 years','value'=>'1-3'], ['name'=>'3-5 years','value'=>'3-5'], ['name'=>'5-10 years','value'=>'5-10'], ['name'=>'10-15 years','value'=>'10-15'], ['name'=>'15+ years','value'=>'15-gt']];
        array_push($filters, $experience);

        //Verified.
        $verified['name'] = 'Verified';
        $verified['filter_var'] = 'verified';
        $verified['data'] = [['name'=>'Verified','value'=>'Yes'], ['name'=>'Un-Verified','value'=>'No']];
        array_push($filters, $verified);

        return response()->json($this->structure(true, "", $filters), 200);
    }

} //Class End Tag.
