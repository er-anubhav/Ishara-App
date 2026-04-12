<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserProfile;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\FileAndFolder;
use App\Models\Folder;
use App\Models\File;
use App\Models\Share;
use App\Models\Bookmark;
use App\Library\TargetPath;
use App\Library\GlobalFunction;
use DB;

class UserController extends Controller
{
    use Structure, FileAndFolder, GlobalFunction;
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('users');
    }

    public function data(Request $request){

        $query = User::query();

        if (!in_array($request->date, [null, '', 'All', 'Any'])) {
            $date_range = explode('-', $request->date);
            $date_form = preg_replace('/\s+/', '', $date_range[0]);
            $date_to = preg_replace('/\s+/', '', $date_range[1]);

            $query = $query->where('created_at', '>=', date('Y-m-d', strtotime($date_form)))
                            ->where('created_at', '<=', date('Y-m-d', strtotime($date_to)));
        }

        if ($request->status && $request->status != 'All') {
            $query->where("is_active", $request->status);
        }

        $data = $query->get();
        return datatables()->of($data)->addColumn('action', function ($data) {

            $button = '<div class="btn-group">';
            // $button .= '<a href="javascript:void()" data-value="'.$data->id.'|'.$data->name.'|'.$data->email.'|'.$data->phone.'" class="edit-btn btn btn-sm btn-secondary"><i class="bx bx-pencil"></i></a>';
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
        })->addColumn('dob', function ($data) {
            return '-';
        })->addColumn('name', function ($data) {
            $name = str_replace(' ', '-', strtolower($data->name));
            $role = strtolower(auth()->user()->role);
            $url = url('/')."/$role/users/profile/$name/".$data->id;
            return '<a href="'.$url.'" data-value="'.$data->id.'" target="_BLANK">'.$data->name.'</a>';
        })->rawColumns(['action', 'dob', 'status', 'name'])->make(true);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function profile_file_explore(Request $request)
    {
        $categories = ['MY_DOCS', 'GENERAL_DOCS', 'BOOKMARKS', 'TEST_REPORTS', 'DOCTOR_PRESCRIPTION', 'DAILY_MEASUREMENTS', 'HOSPITAL_BILLS', 'PHARMACY_RECORDS'];

        $profile_id = $request->id;
        $category = $request->category;
        $data['categories'] = $data['folders'] = $data['files'] = $folders = $files = [];

        if ($request->folder_id > 0) {
            if (in_array($category, $categories) || $category == 'null' || !$category) {
                $files = File::where('profile_id', $profile_id)->where('folder_id', $request->folder_id)
                            ->select('id', 'name', 'folder_id', 'category', 'file_type', 'remarks', 'created_at')->get();

                $beautify = new Beautify();
                $data['files'] = $beautify->files($files, $profile_id);
            }

            elseif($category == 'SHARED_DOCS'){

                if (Share::where('access_id', $request->folder_id)->where('access_type', 'Folder')->where('profile_id', $profile_id)->first()) {
                    
                    $files = File::leftJoin('folders as fol', 'fol.id', 'files.folder_id')->where('files.folder_id', $request->folder)->select(DB::raw("0 as id"), 'files.id as file_id', 'files.name', 'files.folder_id', 'files.category', 'files.file_type', 'files.remarks', 'files.created_at', 'fol.name as folder_name')->get();

                    $beautify = new Beautify();
                    $data['files'] = $beautify->share_files($files);
                }
            }

            elseif($category == 'MY_SHARED_DOCS'){
                
                $files = Share::leftJoin('files as f', 'f.id', 'share.access_id')->leftJoin('folders as fol', 'fol.id', 'f.folder_id')
                                ->where('share.shared_by', $profile_id)->where('f.folder_id', $request->folder_id)->where('share.access_type', 'File')
                                ->select('share.id', 'f.id as file_id', 'f.name', 'f.folder_id', 'f.category', 'f.file_type', 'f.remarks', 'f.created_at', 'fol.name as folder_name', DB::raw("'file' as tag"), 'share.shared_by')
                                ->with(['shared_by_profile' => function($query) {
                                     $query->select(['id', 'name', 'icon', 'relation', 'type']);
                                 }])->get();

                $beautify = new Beautify();
                $data['files'] = $beautify->share_files($files);
            }
        }
        elseif (in_array($category, $categories)) {

            if ($category == 'MY_DOCS') {

                $categories = $this->fileStorageOnlyCategories();
                $data['categories'] = [];

                $folders = DB::table('folders')->where('profile_id', $profile_id)->where('belongs_to', '!=', null)->where('deleted_at', null)
                                                    ->select('belongs_to', DB::raw('count(*) as total'))->groupBy('belongs_to')->pluck('total', 'belongs_to');
                $files = DB::table('files')->where('profile_id', $profile_id)->where('deleted_at', null)->where('category', '!=', null)
                                                    ->select('category', DB::raw('count(*) as total'))->groupBy('category')->pluck('total', 'category');

                
                foreach ($categories as $category) {
                    $category['items'] = 0;
                    if (isset($folders[$category['value']])) {
                        $category['items'] = $folders[$category['value']];
                    }
                    if(isset($files[$category['value']])){
                        $category['items'] = $files[$category['value']];
                    }
                    array_push($data['categories'], $category);
                }

                $folders = Folder::leftJoin('files as f', 'f.folder_id', 'folders.id')->where('folders.profile_id', $profile_id)->where('folders.belongs_to', NUll)
                                        ->where('f.deleted_at', null)
                                        ->select('folders.id', 'folders.name', 'folders.belongs_to', 'folders.created_at', DB::raw('DATE_FORMAT(folders.created_at, "%d %b, %Y") as created_at_m'), DB::raw('count(f.id) as total_files'))
                                                ->groupBy('folders.id')->get();

                $files = File::where('profile_id', $profile_id)->where('folder_id', null)->where('category', null)
                            ->select('id', 'name', 'folder_id', 'category', 'file_type', 'remarks', 'created_at')->get();
            }

            elseif (in_array($category, ['GENERAL_DOCS', 'TEST_REPORTS', 'DOCTOR_PRESCRIPTION', 'HOSPITAL_BILLS', 'PHARMACY_RECORDS'])) {

                $folders = Folder::leftJoin('files as f', 'f.folder_id', 'folders.id')->where('folders.profile_id', $profile_id)->where('folders.belongs_to', $category)
                                        ->where('f.deleted_at', null)
                                        ->select('folders.id', 'folders.name', 'folders.belongs_to', 'folders.created_at', DB::raw('DATE_FORMAT(folders.created_at, "%d %b, %Y") as created_at_m'), DB::raw('count(f.id) as total_files'))
                                                ->groupBy('folders.id')->get();

                $files = File::where('profile_id', $profile_id)->where('folder_id', null)->where('category', $category)
                            ->select('id', 'name', 'folder_id', 'category', 'file_type', 'remarks', 'created_at')->get();
            }

            elseif($category == 'BOOKMARKS'){

                $folders = Bookmark::leftJoin('folders as f', 'f.id', 'bookmarks.asset_id')->leftJoin('files as fs', 'fs.folder_id', 'f.id')
                        ->orWhere('fs.deleted_at', null)->where(['bookmarks.profile_id' => $profile_id, 'bookmarks.asset_type' => 'Folder'])
                        ->where('f.deleted_at', null)->select('bookmarks.id', 'f.id as folder_id', 'f.name', 'f.belongs_to', 'f.created_at', DB::raw('DATE_FORMAT(f.created_at, "%d %b, %Y") as created_at_m'), DB::raw('count(fs.id) as total_files'))->groupBy('bookmarks.id')->get();

                $files = Bookmark::leftJoin('files as f', 'f.id', 'bookmarks.asset_id')->where(['bookmarks.profile_id' => $profile_id, 'bookmarks.asset_type' => 'File'])
                        ->where('f.deleted_at', null)
                        ->select('bookmarks.id', 'f.id as file_id', 'f.name', 'f.folder_id', 'f.category', 'f.file_type', 'f.remarks', 'f.created_at')
                        ->orderBy('bookmarks.created_at', 'desc')->get();
            }

            $beautify = new Beautify();
            $data['folders'] = $beautify->folders($folders, $profile_id);
            $data['files'] = $beautify->files($files, $profile_id);
        }

        elseif($category == 'SHARED_DOCS'){
                
            $folders = Share::leftJoin('folders as f', 'f.id', 'share.access_id')->leftJoin('files as fs', 'fs.folder_id', 'f.id')
                                    ->where('f.deleted_at', null)->where('fs.deleted_at', null)
                                    ->where('share.profile_id', $profile_id)->where('share.access_type', 'Folder')
                                    ->select('share.id', 'f.id as folder_id', 'share.shared_by', 'f.name', 'f.belongs_to', 'f.created_at', DB::raw('DATE_FORMAT(f.created_at, "%d %b, %Y") as created_at_m'), DB::raw('count(fs.id) as total_files'))
                                    ->with(['shared_by_profile' => function($query) {
                                         $query->select(['id', 'name', 'icon', 'relation', 'type']);
                                     }])->groupBy('share.id')->get();

            $files = Share::leftJoin('files as f', 'f.id', 'share.access_id')->leftJoin('folders as fol', 'fol.id', 'f.folder_id')
                                ->where('f.deleted_at', null)->where('share.profile_id', $profile_id)->where('share.access_type', 'File')
                                ->select('share.id', 'f.id as file_id', 'f.name', 'f.folder_id', 'f.category', 'f.file_type', 'f.remarks', 'f.created_at', 'fol.name as folder_name', DB::raw("'file' as tag"), 'share.shared_by')
                                ->with(['shared_by_profile' => function($query) {
                                     $query->select(['id', 'name', 'icon', 'relation', 'type']);
                                 }])->get();

            $beautify = new Beautify();
            $data['folders'] = $folders;
            $data['files'] = $beautify->share_files($files);
        }

        elseif($category == 'MY_SHARED_DOCS'){
            
            $folders = Share::leftJoin('folders as f', 'f.id', 'share.access_id')->leftJoin('files as fs', 'fs.folder_id', 'f.id')
                                    ->where('f.deleted_at', null)->where('fs.deleted_at', null)
                                    ->where('share.shared_by', $profile_id)->where('share.access_type', 'Folder')
                                    ->select('share.id', 'f.id as folder_id', 'share.shared_by', 'f.name', 'f.belongs_to', 'f.created_at', DB::raw('DATE_FORMAT(f.created_at, "%d %b, %Y") as created_at_m'), DB::raw('count(fs.id) as total_files'))
                                    ->with(['shared_by_profile' => function($query) {
                                         $query->select(['id', 'name', 'icon', 'relation', 'type']);
                                     }])->groupBy('share.id')->get();

            $files = Share::leftJoin('files as f', 'f.id', 'share.access_id')->leftJoin('folders as fol', 'fol.id', 'f.folder_id')
                                ->where('f.deleted_at', null)->where('share.shared_by', $profile_id)->where('share.access_type', 'File')
                                ->select('share.id', 'f.id as file_id', 'f.name', 'f.folder_id', 'f.category', 'f.file_type', 'f.remarks', 'f.created_at', 'fol.name as folder_name', DB::raw("'file' as tag"), 'share.shared_by')
                                ->with(['shared_by_profile' => function($query) {
                                     $query->select(['id', 'name', 'icon', 'relation', 'type']);
                                 }])->get();

            $beautify = new Beautify();
            $data['folders'] = $folders;
            $data['files'] = $beautify->share_files($files);
        }
        return response()->json($this->structure(true, 'My Docs', $data), 200);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function profile_view(Request $request)
    {
        $profile = UserProfile::find($request->id);
        $path = TargetPath::common_storage($this->profileFolderName($request->id));
        $storage = $this->format_file_size($this->folder_Size($path));
        return view('user_profile_view', ['profile' => $profile, 'storage' => $storage, 'profile_id' => $request->id]);
    }


    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(Request $request)
    {
        $user_id = isset($request->id) ? $request->id : 0 ;
        $user = User::find($user_id);
        $profiles = $user->profiles();
        return view('user_profile', ['user' => $user, 'profiles' => $profiles]);
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
        $response = User::where('id', $request->id)->update($data);

        if ($response > 0) {
            if ($request->status == 'delete') {
              return response()->json(['error' => false, 'message' => 'Deleted Succesfully!']);
            }
            return response()->json(['error' => false, 'message' =>'Status Updated Succesfully!']);
        }
        return response()->json(['error'=> true, 'message' => 'Somthing went wrong, try again !']);
    }
}
