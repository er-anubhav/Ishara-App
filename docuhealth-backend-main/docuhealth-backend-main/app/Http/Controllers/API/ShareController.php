<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Library\FileAndFolder;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\TargetPath;
use App\Library\GlobalFunction;
use App\Library\DisplayPath;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\Share;
use App\Models\Folder;
use App\Models\File as FileModal;
use File;
use DB;

class ShareController extends Controller
{
    // Structure of response API.
    use Structure, FileAndFolder, GlobalFunction;

    public function share(Request $request)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'profile_id' => 'required|String|max:255',
              'item_id' => 'required',
              'item_type' => 'required',
            ], ['item_id.required'=>'File or Folder not found', 'item_type.required'=>'File or Folder not found']);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            $share_to_profile_id = $request->profile_id;
            if ($share_to_profile = UserProfile::find($share_to_profile_id)) {
                
                $requested_file_type = ucfirst($request->item_type);
                if ($requested_file_type == 'File') {
                    
                    if ($file = FileModal::where('profile_id', $profile_id)->where('id', $request->item_id)->first()) {
                        
                        $share = new Share();
                        $share->profile_id  = $share_to_profile->id;
                        $share->shared_by   = $profile_id;
                        $share->access_id  = $file->id;
                        $share->access_type = $requested_file_type;

                        try {
                            $share->save();
                            return response()->json($this->structure(true, 'File shared to '.$share_to_profile->name), 200);
                        } catch (\Exception $e) {
                            return response()->json($this->structure(false, 'Something went wrong!'), 200);
                        }
                    }
                }elseif($requested_file_type == 'Folder'){

                    if ($folder = Folder::where('profile_id', $profile_id)->where('id', $request->item_id)->first()) {
                        
                        $share = new Share();
                        $share->profile_id  = $share_to_profile->id;
                        $share->shared_by   = $profile_id;
                        $share->access_id  = $folder->id;
                        $share->access_type = $requested_file_type;

                        try {
                            $share->save();
                            return response()->json($this->structure(true, 'Folder shared to '.$share_to_profile->name), 200);
                        } catch (\Exception $e) {
                            return response()->json($this->structure(false, 'Something went wrong!'), 200);
                        }
                    }
                }
                return response()->json($this->structure(false, "$requested_file_type not found!"), 200);
            }
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function share_to_family(Request $request)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'profile_id' => 'required|String|max:255',
              'item_id' => 'required',
              'item_type' => 'required',
            ], ['item_id.required'=>'File or Folder not found', 'item_type.required'=>'File or Folder not found']);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            $share_to_profile_id = $request->profile_id;
            if ($share_to_profile = UserProfile::find($share_to_profile_id)) {
                
                if ($this->isMyFamilyMember($share_to_profile->id)) {
                    
                    $requested_file_type = ucfirst($request->item_type);
                    if ($requested_file_type == 'File') {
                        if ($file = FileModal::where('profile_id', $profile_id)->where('id', $request->item_id)->with('folder')->first()) {
                            
                            //Current FOlder...
                            $myFolder = $this->profileFolderName($profile_id);
                            $currentDir = TargetPath::common_storage($myFolder);
                            $file_with_current_dir = "$currentDir/".$file->name;
                            $thumbnail_file_with_current_dir = "$currentDir/thumbnail/".$file->name;

                            //If file already have in another folder.
                            if ($file->folder) {
                                $currentDir = "$currentDir/".$file->folder->name;
                                $file_with_current_dir = "$currentDir/".$file->name;
                                $thumbnail_file_with_current_dir = "$currentDir/thumbnail/".$file->name;
                            }

                            //check the file exist or not on the target folder.
                            if (file_exists($file_with_current_dir)) {

                                $fileCopy = new FileModal();
                                $fileCopy->profile_id = $share_to_profile->id;
                                $fileCopy->category = $file->category;
                                $fileCopy->name = $file->name;
                                $fileCopy->file_type = $file->file_type;
                                $fileCopy->remarks = $file->remarks;

                                //Target FOlder...
                                $targetFolder = $this->profileFolderName($share_to_profile->id);
                                $targetDir = TargetPath::common_storage($targetFolder);
                                $file_with_target_dir = "$targetDir/".$file->name;
                                $thumbnail_file_with_target_dir = "$targetDir/thumbnail/".$file->name;

                                //If file already have in another folder.
                                if ($file->folder) {
                                    
                                    $targetDir = "$targetDir/".$file->folder->name;
                                    if (!(File::isDirectory($targetDir))) {
                                        File::makeDirectory($targetDir, 0777, true, true);
                                        File::makeDirectory("$targetDir/thumbnail/", 0777, true, true);
                                    }

                                    $file_with_target_dir = "$targetDir/".$file->name;
                                    $thumbnail_file_with_target_dir = "$targetDir/thumbnail/".$file->name;
                                    $fileCopy->folder_id = $file->folder->id;
                                }else{
                                    if (!(File::isDirectory($targetDir))) {
                                        File::makeDirectory($targetDir, 0777, true, true);
                                        File::makeDirectory("$targetDir/thumbnail/", 0777, true, true);
                                    }
                                }

                                //Change the file name, If file exist on target folder.
                                if (file_exists($file_with_target_dir)) {
                                    $file_name = pathinfo($file->name, PATHINFO_FILENAME);
                                    $ext = pathinfo($file->name, PATHINFO_EXTENSION);

                                    $fileCopy->name = $file_name.'_copy_'.date('ymdhis').".$ext";
                                    $file_with_target_dir = "$targetDir/".$fileCopy->name;
                                    $thumbnail_file_with_target_dir = "$targetDir/thumbnail/".$fileCopy->name;
                                }

                                try {
                                    copy($file_with_current_dir, $file_with_target_dir);
                                    if (pathinfo($fileCopy->name, PATHINFO_EXTENSION) != 'pdf') {
                                        copy($thumbnail_file_with_current_dir, $thumbnail_file_with_target_dir);
                                    }

                                    if ($fileCopy->save()) {

                                        if ($folder = $file->folder) {
                                            //copy folder to target profile
                                            $folderCopy = new Folder();

                                            $folderCopy->profile_id = $share_to_profile->id;
                                            $folderCopy->name = $folder->name;
                                            $folderCopy->belongs_to = $folder->belongs_to;

                                            $folderCopy->save();
                                        }
                                        return response()->json($this->structure(true, 'File shared to '.$share_to_profile->name), 200);
                                    }
                                } catch (\Exception $e) {
                                    return response()->json($this->structure(false, 'Something went wrong!'), 200);                        
                                }
                            }
                            return response()->json($this->structure(false, 'File not found!'), 200);
                        }
                    }elseif($requested_file_type == 'Folder'){

                        if ($folder = Folder::where('profile_id', $profile_id)->where('id', $request->item_id)->with('files')->first()) {
                            
                            //Current FOlder...
                            $myFolder = $this->profileFolderName($profile_id);
                            $currentDir = TargetPath::common_storage(("$myFolder/".$folder->name));

                            //Target FOlder...
                            $targetFolder = $this->profileFolderName($share_to_profile->id);
                            $targetDir = TargetPath::common_storage(("$targetFolder/".$folder->name));

                            try {
                                
                                //copy folder to target profile
                                $folderCopy = new Folder();

                                $folderCopy->profile_id = $share_to_profile->id;
                                $folderCopy->name = $folder->name;
                                $folderCopy->belongs_to = $folder->belongs_to;

                                $folderCopy->save();

                                //copy files to target profile, If have any...
                                if ($folder->files) {
                                    
                                    $files = $folder->files;
                                    foreach ($files as $file) {
                                        
                                        $fileCopy = new FileModal();
                                        $fileCopy->profile_id = $share_to_profile->id;
                                        $fileCopy->folder_id = $file->folder_id;
                                        $fileCopy->category = $file->category;
                                        $fileCopy->name = $file->name;
                                        $fileCopy->file_type = $file->file_type;
                                        $fileCopy->remarks = $file->remarks;

                                        $fileCopy->save();
                                    }
                                }

                                //Actual file copy.
                                if (File::isDirectory($currentDir)) {
                                    File::copyDirectory($currentDir, $targetDir);
                                }else{
                                    File::makeDirectory($currentDir, 0777, true, true);
                                    File::makeDirectory($targetDir, 0777, true, true);
                                }

                                return response()->json($this->structure(true, 'Folder shared to '.$share_to_profile->name), 200);
                            } catch (\Exception $e) {
                                return response()->json($this->structure(false, 'Something went wrong!'), 200);
                            }
                        }
                    }
                    return response()->json($this->structure(false, "$requested_file_type not found!"), 200);
                }
                return response()->json($this->structure(false, 'Seems like this profile is not listed to your family member!'), 200);
            }
            return response()->json($this->structure(false, 'Family member profile not found!'), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function get_shared(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {                        

            //Page Calculations.
            $data_records['pagination'] = true;
            $data_records['page'] = request('page') ? intval(request('page')) : 1 ;
            $data_records['limit'] = request('limit') ? request('limit') : 6 ;
            $data_records['start'] = $data_records['page'] == 1 ? 0 : ($data_records['page'] -1 ) * $data_records['limit'] ;

            $folders = [];
            if ($data_records['page'] <= 1  && !$request->folder) {

                //FOlders____
                $folders = Share::leftJoin('folders as f', 'f.id', 'share.access_id')->where('share.profile_id', $profile_id)->where('share.access_type', 'Folder')
                                        ->select('share.id', 'f.id as folder_id', 'share.shared_by', 'f.name', 'f.belongs_to', 'f.created_at', DB::raw("'folder' as tag"))
                                        ->with(['shared_by_profile' => function($query) {
                                             $query->select(['id', 'name', 'icon', 'relation', 'type']);
                                         }]);
                if ($request->search) 
                    $folders = $folders->where('f.name', 'like', '%' . $request->search . '%');

                if ($request->sort_by == 'date')
                    $folders = $folders->orderBy('f.updated_at');

                if ($request->sort_by == 'name')
                    $folders = $folders->orderBy('f.name');

                $folders = $folders->get()->toArray();
            }

            //FIles____
            if ($request->folder){
                $files = [];
                if (Share::where('access_id', $request->folder)->where('access_type', 'Folder')->where('profile_id', $profile_id)->first()) {
                    
                    $files = FileModal::leftJoin('folders as fol', 'fol.id', 'files.folder_id')->where('files.folder_id', $request->folder)->select(DB::raw("0 as id"), 'files.id as file_id', 'files.name', 'files.folder_id', 'files.category', 'files.file_type', 'files.remarks', 'files.created_at', 'fol.name as folder_name', DB::raw("'file' as tag"));

                    if ($request->search) 
                        $files = $files->where('files.name', 'like', '%' . $request->search . '%');
                
                    if ($request->sort_by == 'date')
                        $files = $files->orderBy('files.updated_at');

                    if ($request->sort_by == 'name')
                        $files = $files->orderBy('files.name');
                }
            }else{

                $files = Share::leftJoin('files as f', 'f.id', 'share.access_id')->leftJoin('folders as fol', 'fol.id', 'f.folder_id')
                                    ->where('share.profile_id', $profile_id)->where('share.access_type', 'File')
                                    ->select('share.id', 'f.id as file_id', 'f.name', 'f.folder_id', 'f.category', 'f.file_type', 'f.remarks', 'f.created_at', 'fol.name as folder_name', DB::raw("'file' as tag"), 'share.shared_by')
                                    ->with(['shared_by_profile' => function($query) {
                                         $query->select(['id', 'name', 'icon', 'relation', 'type']);
                                     }]);

                if ($request->search) 
                    $files = $files->where('f.name', 'like', '%' . $request->search . '%');
                
                if ($request->sort_by == 'date')
                    $files = $files->orderBy('f.updated_at');

                if ($request->sort_by == 'name')
                    $files = $files->orderBy('f.name');
            }

            //count the total lead data.
            $data_records['total_records'] = $files->count();
            $files = $files->skip($data_records['start'])->take($data_records['limit'])->get();

            $beautify = new Beautify();
            $files = $beautify->share_files($files);

            $data['data'] = array_merge($folders, $files);
            $data['data_records'] = $data_records;                  
            return response()->json($this->structure(true, 'Shared', $data), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function get_my_shared(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {                        

            //Page Calculations.
            $data_records['pagination'] = true;
            $data_records['page'] = request('page') ? intval(request('page')) : 1 ;
            $data_records['limit'] = request('limit') ? request('limit') : 6 ;
            $data_records['start'] = $data_records['page'] == 1 ? 0 : ($data_records['page'] -1 ) * $data_records['limit'] ;

            $folders = [];
            if ($data_records['page'] <= 1) {
                //FOlders____
                $folders = Share::leftJoin('folders as f', 'f.id', 'share.access_id')->where('share.shared_by', $profile_id)->where('share.access_type', 'Folder')
                                        ->select('share.id', 'f.id as folder_id', 'f.name', 'f.belongs_to', 'f.created_at', DB::raw("'folder' as tag"));

                if ($request->search) 
                    $folders = $folders->where('f.name', 'like', '%' . $request->search . '%');

                if ($request->sort_by == 'date')
                    $folders = $folders->orderBy('f.updated_at');

                if ($request->sort_by == 'name')
                    $folders = $folders->orderBy('f.name');

                $folders = $folders->get()->unique('folder_id')->toArray();
            }

            //FIles____
            $files = Share::leftJoin('files as f', 'f.id', 'share.access_id')->leftJoin('folders as fol', 'fol.id', 'f.folder_id')
                                    ->where('share.shared_by', $profile_id)->where('share.access_type', 'File')
                                    ->select('share.id', 'f.id as file_id', 'f.name', 'f.folder_id', 'f.category', 'f.file_type', 'f.remarks', 'f.created_at', 'share.shared_by', 'fol.name as folder_name', DB::raw("'file' as tag"));
            if ($request->search) 
                $files = $files->where('f.name', 'like', '%' . $request->search . '%');
            
            if ($request->sort_by == 'date')
                $files = $files->orderBy('f.updated_at');

            if ($request->sort_by == 'name')
                $files = $files->orderBy('f.name');

            //count the total lead data.
            $data_records['total_records'] = $files->count();
            $files = $files->skip($data_records['start'])->take($data_records['limit'])->get()->unique('file_id');

            $beautify = new Beautify();
            $files = $beautify->share_files($files);

            $data['data'] = array_merge($folders, $files);
            $data['data_records'] = $data_records;                  
            return response()->json($this->structure(true, 'Shared', $data), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function shared_remove(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {
            if ($share = Share::find($request->shared_id)) {
                if ($share->profile_id == $profile_id) {
                   try {
                       $share->delete();
                       return response()->json($this->structure(false, "Removed"), 200);
                   } catch (\Exception $e) {
                       return response()->json($this->structure(false, "Internal server error!"), 200);
                   }
                }
            }
            return response()->json($this->structure(false, "Shared file or folder not found!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function my_shared_remove(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {
            if ($share = Share::find($request->shared_id)) {

                if ($share->shared_by == $profile_id) {
                    if ($profile = UserProfile::find($request->profile_id)) {

                        try {
                           Share::where('share.shared_by', $profile_id)->where('share.profile_id', $profile->id)
                                            ->where('share.access_type', $share->access_type)->where('share.access_id', $share->access_id)->delete();
                           return response()->json($this->structure(false, "Removed"), 200);
                        } catch (\Exception $e) {
                           return response()->json($this->structure(false, "Internal server error!"), 200);
                        }
                    }
                    return response()->json($this->structure(false, "Shared profile not found!"), 200);
                }
            }
            return response()->json($this->structure(false, "Shared file or folder not found!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function get_my_shared_profiles(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {
            if ($share = Share::find($request->id)) {
                if ($share->shared_by == $profile_id) {
                   
                   $profile_ids = Share::where('share.shared_by', $profile_id)->where('share.access_type', $share->access_type)
                                                                        ->where('share.access_id', $share->access_id)->pluck('profile_id');
                   $profiles = UserProfile::whereIn('id', $profile_ids)->select('id', 'name', 'icon', 'relation', 'type')->get();

                   return response()->json($this->structure(false, "", $profiles), 200);
                }
            }
            return response()->json($this->structure(false, "Shared file or folder not found!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function check_is_phone_our_member(Request $request)
    {
        $user = User::where('phone', $request->phone)->first();

        if ($user) {
            
            $profile = $user->profile;
            if (isset($profile)) {

                $beautify = new Beautify();

                $data['id'] = $profile->id;
                $data['name'] = $profile->name;
                $data['phone'] = $request->phone;
                $data['icon'] = $profile->icon;
                return response()->json($this->structure(true, "User Found.", $data), 200);
            }
            return response()->json($this->structure(false, "Seems like profile not created or active!"), 200);
        }
        return response()->json($this->structure(false, "This phone is not registered with us."), 200);
    }

    private function isMyFamilyMember($family_profile_id = 0)
    {
        $profile_ids = User::find( (isset(auth('api')->user()->id) ? auth('api')->user()->id : 0) )->profilesID();

        return in_array($family_profile_id, $profile_ids) ? true : false ;
    }

    public function direct_share(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            if ($request->type == 'file') {
                    
                if ($file = FileModal::where('profile_id', $profile_id)->where('id', $request->id)->first()) {
                    
                    $targetDir = $this->profileFolderName($profile_id);
                    $folder = '';
                    if (isset($file->folder->name)) {
                        $folder = $file->folder->name.'/';
                    }
                   
                    $path = "$targetDir/$folder".$file->name;
                    $data['public_link'] = url('api/v1/share/assets?accessId='.$this->encrypt_decrypt('encrypt', $path)); 
                    return response()->json($this->structure(true, 'Public link generated.', $data), 200);
                }
            }
            return response()->json($this->structure(false, "File not found!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function assets_public_access(Request $request)
    {
        $file = public_path('app-assets/images/icon/no-image.png');

        if ($request->accessId) {
            
            $path = $this->encrypt_decrypt('decrypt', $request->accessId);
            $image = TargetPath::common_storage($path);
            $file = file_exists($image) ? $image : $file ;
        }
        return response()->file($file);
    }

} //Class End Tag.
