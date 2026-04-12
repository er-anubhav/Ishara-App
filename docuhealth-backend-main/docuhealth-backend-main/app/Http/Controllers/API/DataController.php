<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\DisplayPath;
use App\Models\Notification;
use App\Models\Banner;
use App\Models\Doctor;
use App\Models\DoctorAddress;
use App\Models\UserProfile;
use App\Models\Specialization;
use App\Models\Folder;
use App\Models\File as FileModal;
use DB;

class DataController extends Controller
{
    // Structure of response API.
    use Structure;

    public function notifications(Request $request){

        $user_id = isset(auth('api')->user()->id) ? auth('api')->user()->id : 0;

        $notifications =  Notification::where('user_id', $user_id)->orWhere('user_id', NULL)->where('user_type', 'User')->orWhere('user_type', null)->get();
        return response()->json($this->structure(true, "Notifications", $notifications), 200);
    }

    public function banners(Request $request){

        $banners =  Banner::where('is_active', 'Yes')->get();

        $beautify = new Beautify();
        $banners = $beautify->banners($banners);
        return response()->json($this->structure(true, "Banners", $banners), 200);
    }

    public function suggetions(Request $request){

        $key = ucfirst($request->key);
        if ($key == 'Lab') {
            $suggetions =  Doctor::where('is_active', 'Yes')->where('role', $key)->inRandomOrder()->limit(5)->pluck('name');
        } elseif($key == 'Hospital'){
            $suggetions =  Doctor::where('is_active', 'Yes')->where('role', $key)->inRandomOrder()->limit(5)->pluck('name');
        }else{
            $suggetions =  Doctor::where('is_active', 'Yes')->where('role', 'Doctor')->inRandomOrder()->limit(5)->pluck('name');
        }

        return response()->json($this->structure(true, "Suggetions", $suggetions), 200);
    }

    public function categories(Request $request){

        $categories =  Specialization::where('is_active', 'Yes')->select('id', 'name', 'icon')->orderBy('position', 'asc')->get();

        $beautify = new Beautify();
        $categories = $beautify->categories($categories);
        return response()->json($this->structure(true, "Categories", $categories), 200);
    }

    public function folders_and_files(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            //Page Calculations.
            $data_records['pagination'] = true;
            $data_records['page'] = request('page') ? intval(request('page')) : 1 ;
            $data_records['limit'] = request('limit') ? request('limit') : 6 ;
            $data_records['start'] = $data_records['page'] == 1 ? 0 : ($data_records['page'] -1 ) * $data_records['limit'] ;

            $folders = [];
            if ($data_records['page'] <= 1 && !$request->folder) {

                //Folders
                $folders = Folder::where('profile_id', $profile_id);
                //Filters
                if ($request->search) {
                    $folders = $folders->where('name', 'like', '%' . $request->search . '%');
                }
                if ($request->category) {
                    $folders = $folders->where('belongs_to', $request->category);
                }else{
                    $folders = $folders->where('belongs_to', NUll);
                }
                if ($request->sort_by == 'date') {
                    $folders = $folders->orderBy('updated_at');
                }
                if ($request->sort_by == 'name') {
                    $folders = $folders->orderBy('name');
                }
                $folders = $folders->select('id', 'name', 'belongs_to', 'created_at', DB::raw("'folder' as tag"))->get();
            }

            //Files
            $files = FileModal::where('profile_id', $request->profile->id);
            //Filters
            if ($request->search) {
                $files = $files->where('name', 'like', '%' . $request->search . '%');
            }
            if ($request->category) {
                $files = $files->where('category', $request->category);
            }else{
                $files = $files->where('category', NUll);
            }
            if ($request->folder) {
                $files = $files->where('folder_id', $request->folder);
            }else{
                $files = $files->where('folder_id', NUll);
            }
            if ($request->sort_by == 'date') {
                $files = $files->orderBy('updated_at');
            }
            if ($request->sort_by == 'name') {
                $files = $files->orderBy('name');
            }

            //count the total lead data.
            $data_records['total_records'] = $files->count();

            $files = $files->skip($data_records['start'])->take($data_records['limit'])
                        ->addSelect('id', 'name', 'folder_id', 'category', 'file_type', 'remarks', 'created_at', DB::raw("'file' as tag"))
                        ->with('folder')
                        ->get();

            $beautify = new Beautify();
            $folders = $beautify->folders($folders, $profile_id);
            $files = $beautify->files($files, $profile_id);
            $data['data'] = array_merge($folders, $files);
            $data['data_records'] = $data_records;

            return response()->json($this->structure(true, "Folders & Files", $data), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }
       
} //Class End Tag.
