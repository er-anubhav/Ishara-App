<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use App\Library\FileAndFolder;
use App\Library\DisplayPath;
use App\Library\TargetPath;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\Image;
use App\Models\User;
use App\Models\Share;
use App\Models\File as FileModal;
use App\Models\FileModel as SecureFile;
use App\Models\Folder;
use Illuminate\Support\Facades\Storage;
use File;

class FileController extends Controller
{
    // Structure of response API.
    use Structure, FileAndFolder, Image;

    public function file_uploader(Request $request) 
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|mimes:gif,jpg,bmp,png,jpeg,pjpeg,pdf', 
        ]);
        if ($validator->fails()) {
             return response()->json($this->structure(false, $validator->errors()->first()), 200);
        } 

        if ($request->file('file') != '') {

            $file = $request->file('file');
            $temp_name = $_FILES["file"]["tmp_name"];
            $file_original_name = $file->getClientOriginalName();
            $file_name = pathinfo($file_original_name, PATHINFO_FILENAME);
            $ext = pathinfo($file_original_name, PATHINFO_EXTENSION);

            //Create folder by profile or given name.
            $folder = empty($request->target_path) ? $this->profileFolderName($request->profile->id) 
                                                        : str_replace(' ', '_', strtoupper($request->target_path));
            //For original image
            $targetDir = TargetPath::common_storage($folder);
            if (!(File::isDirectory($targetDir))) {
                File::makeDirectory($targetDir, 0777, true, true);
            }
            $file_name_with_target_dir = "$targetDir/$file_original_name";
            $file_name = file_exists($file_name_with_target_dir) ? $file_name.'_copy_'.date('ymdhis').".$ext" : $file_original_name ;

            if ($ext != 'pdf') {
                
                //For thumbnail image
                $targetThumbnailDir = "$targetDir/thumbnail";
                if (!(File::isDirectory($targetThumbnailDir))) {
                    File::makeDirectory($targetThumbnailDir, 0777, true, true);
                }
                $thumbnail_file_name_with_target_dir = "$targetThumbnailDir/$file_name";
                $file_name = file_exists($thumbnail_file_name_with_target_dir) ? $file_name.'_copy_'.date('ymdhis').".$ext" : $file_name ;

                \App\Library\StorageHelper::storeUploadedFile($file, $targetDir, $file_name);
                $this->resizeImage("$targetDir/$file_name", "$targetThumbnailDir/$file_name");
            }else{
                \App\Library\StorageHelper::storeUploadedFile($file, $targetDir, $file_name);
            }
            
            $data['file'] = DisplayPath::common_storage()."/$folder/$file_name";
            $data['file_name'] = $file_name;
            $data['target_path'] = $folder;
            return response()->json($this->structure(true, 'File uploaded successfully.', [$data]), 200);
        }
        return response()->json($this->structure(false, 'File Not Found!'), 200);
    }

    public function store(Request $request)
    {
       $validator = Validator::make($request->all(), [
            'files_name' => 'required',
            'destination' => 'nullable',
            'remarks' => 'nullable|string',
        ]);
        if ($validator->fails()) {
             return response()->json($this->structure(false, $validator->errors()->first()), 200);
        } 

        if (isset($request->profile->id)) {
            
            $belongs_to = $failure = $folder_id = null;
            $files = is_array($request->files_name) ? $request->files_name : explode(',', $request->files_name);
            $files_rename = is_array($request->files_rename) ? $request->files_rename : explode(',', $request->files_rename);

            $myFolder = $this->profileFolderName($request->profile->id);
            $rootDir = $targetDir = TargetPath::common_storage($myFolder);
            $rootThumbnailDir = $targetThumbnailDir = "$rootDir/thumbnail";

            if($request->destination){

                if (in_array($request->destination, $this->fileCategories())) {
                    $belongs_to = $request->destination;
                }
                else if ($folder = Folder::find($request->destination)) {
                    $belongs_to = $folder->belongs_to;
                    $folder_id = $folder->id;
                    $targetDir = "$targetDir/".$folder->name;
                    $targetThumbnailDir = "$targetDir/thumbnail";
                    if (!(File::isDirectory($targetDir))) {
                        File::makeDirectory($targetDir, 0777, true, true);
                    }
                    if (!(File::isDirectory($targetThumbnailDir))) {
                        File::makeDirectory($targetThumbnailDir, 0777, true, true);
                    }
                }
            }

            if (is_array($files)) {

                for ($i=0; $i < sizeof($files); $i++) { 
                    
                    if(isset($files[$i])){

                        $file = new FileModal();

                        $file_type = pathinfo($files[$i], PATHINFO_EXTENSION) == 'pdf' ? 'document' : 'image' ;
                        $ext = pathinfo($files[$i], PATHINFO_EXTENSION);
                        $file_original_name = $files[$i];

                        //when the file name is not set.
                        if (isset($files_rename[$i])) {
                            if ($files_rename[$i] == '') {
                                $file__rename = 'DOC_'.date('ymdhis').$request->profile->id.'.'.$ext;
                            }else{
                                $file__rename = $files_rename[$i].'.'.$ext;
                            }
                        }else{
                            $file__rename = $files[$i];
                        }

                        $file->name = $file__rename;    
                        $file->profile_id = $request->profile->id;
                        $file->folder_id = $folder_id;
                        $file->category = $belongs_to;   
                        $file->file_type = $file_type;   
                        $file->remarks = $request->remarks;

                        try {

                            if (($rootDir != $targetDir) || ($file_original_name != $file__rename)) {
                                
                                $file_with_target_dir = "$targetDir/".$file->name;

                                //rename the file, if already exist with same name.
                                $file_name = file_exists($file_with_target_dir) ? $file->name.'_copy_'.date('ymdhis').".$ext" : $file->name ;

                                $file_with_current_dir = "$rootDir/".$file_original_name;
                                $file_with_target_dir = "$targetDir/$file_name";

                                $thumbnail_file_with_current_dir = "$rootThumbnailDir/".$file_original_name;
                                $thumbnail_file_with_target_dir = "$targetThumbnailDir/$file_name";

                                $file->name = $file_name;

                                //file move to target folder.
                                rename($file_with_current_dir, $file_with_target_dir);

                                //thumbnail file move to target folder.
                                if ($file_type == 'image') {
                                    rename($thumbnail_file_with_current_dir, $thumbnail_file_with_target_dir);
                                }
                            }
                            $file->save();
                        } catch (\Exception $e) {
                            // $failure = true;
                            return response()->json($this->structure(false, $e->getMessage()), 200);
                        }
                    }
                }
            }

            if (!$failure) {
                return response()->json($this->structure(true, 'Uploaded successfully'), 200);
            }
            return response()->json($this->structure(false, 'All files are not uploaded'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function get(Request $request)
    {
        if(isset($request->profile->id)){

            //Page Calculations.
            $data_records['pagination'] = true;
            $data_records['page'] = request('page') ? intval(request('page')) : 1 ;
            $data_records['limit'] = request('limit') ? request('limit') : 6 ;
            $data_records['start'] = $data_records['page'] == 1 ? 0 : ($data_records['page'] -1 ) * $data_records['limit'] ;
            
            $files = FileModal::where('profile_id', $request->profile->id);

            //Filters
            if ($request->category) {
                $files = $files->where('category', $request->category);
            }
            if ($request->folder) {
                $files = $files->where('folder_id', $request->folder);
            }
            if ($request->sort_by == 'date') {
                $files = $files->orderBy('updated_at', 'desc');
            }
            if ($request->sort_by == 'name') {
                $files = $files->orderBy('name');
            }

            //count the total lead data.
            $data_records['total_records'] = $files->count();

            $files = $files->skip($data_records['start'])->take($data_records['limit'])
                        ->select('id', 'name', 'folder_id', 'category', 'file_type', 'remarks', 'created_at')
                        ->with('folder')
                        ->orderBy('updated_at')
                        ->get();

            $beautify = new Beautify();
            $files = $beautify->files($files, $request->profile->id);
            return response()->json($this->structure(true, 'Files', ['data' => $files, 'data_records' => $data_records]), 200);
            
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function download(Request $request)
    {
        if (isset($request->profile->id)) {

            $file = FileModal::find($request->file_id);
            if ($file) {

                if ($file->profile_id == $request->profile->id) {

                    $secureFile = SecureFile::where('user_id', $request->profile->user_id)
                        ->where('original_name', $file->name)
                        ->latest('id')
                        ->first();

                    if ($secureFile && config('filesystems.default') === 's3') {
                        return Storage::disk('s3')->response($secureFile->s3_path, $file->name);
                    }

                    $folder = $this->profileFolderName($request->profile->id);
                    $rootDir = $targetDir = TargetPath::common_storage($folder);
                    $file_with_current_dir = "$rootDir/".$file->name;

                    if ($file->folder) {
                        $targetDir = "$targetDir/".$file->folder->name;
                        $file_with_current_dir = "$targetDir/".$file->name;
                    }
                    return Response::download($file_with_current_dir);
                }
            }
            return response()->json($this->structure(false, 'File not found!'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function rename(Request $request)
    {
       $validator = Validator::make($request->all(), [
            'file_id' => 'required',
            'name' => 'nullable|string|max:25',
            'remarks' => 'nullable|string'
        ]);
        if ($validator->fails()) {
             return response()->json($this->structure(false, $validator->errors()->first()), 200);
        } 

        if (isset($request->profile->id)) {

            $file = FileModal::find($request->file_id);

            if ($file) {

                if ($file->profile_id == $request->profile->id) {
                     
                    $folder = $this->profileFolderName($request->profile->id);
                        
                    $rootDir = $targetDir = TargetPath::common_storage($folder);
                    $file_with_current_dir = "$rootDir/".$file->name;
                    $thumbnail_file_with_current_dir = "$rootDir/thumbnail/".$file->name;

                    //If file already have in another folder.
                    if ($file->folder_id) {
                        if ($folder = Folder::find($file->folder_id)) {
                            $targetDir = "$targetDir/".$folder->name;
                            $file_with_current_dir = "$targetDir/".$file->name;
                            $thumbnail_file_with_current_dir = "$targetDir/thumbnail/".$file->name;
                        }
                    }

                    if (file_exists($file_with_current_dir)) {

                        $ext = pathinfo($file->name, PATHINFO_EXTENSION);
                        $file_name = $request->name.".$ext";

                        $file_with_target_dir = "$targetDir/$file_name"; 
                        $thumbnail_file_with_target_dir = "$targetDir/thumbnail/$file_name";

                        if (file_exists($file_with_target_dir) || file_exists($thumbnail_file_with_target_dir)) {
                            $file_name = $file_name.'_copy_'.date('ymdhis').".$ext";

                            $file_with_target_dir = "$targetDir/$file_name"; 
                            $thumbnail_file_with_target_dir = "$targetDir/thumbnail/$file_name";
                        }

                        if ($ext != 'pdf') {
                            if (file_exists($thumbnail_file_with_current_dir)) {
                                rename($thumbnail_file_with_current_dir, $thumbnail_file_with_target_dir);
                            }else{
                                $this->resizeImage($file_with_current_dir, $thumbnail_file_with_target_dir);
                            }
                        }

                        rename($file_with_current_dir, $file_with_target_dir);

                        $file->name = $file_name;

                        if ($request->remarks)
                            $file->remarks = $request->remarks;

                        if ($file->save()) {
                            return response()->json($this->structure(true, 'File name changed!'), 200);
                        }
                    }
                }
            }
            return response()->json($this->structure(false, 'File not found!'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function move(Request $request)
    {
       $validator = Validator::make($request->all(), [
            'file_id' => 'required',
            'distination' => 'nullable'
        ]);
        if ($validator->fails()) {
             return response()->json($this->structure(false, $validator->errors()->first()), 200);
        } 

        if (isset($request->profile->id)) {

            $file = FileModal::find($request->file_id);
        
            if ($file) {
                    
                if ($file->profile_id == $request->profile->id) {
                    
                    $folder = $this->profileFolderName($request->profile->id);
                        
                    $rootDir = $targetDir = TargetPath::common_storage($folder);
                    $file_with_current_dir = "$targetDir/".$file->name;
                    $thumbnail_file_with_current_dir = "$targetDir/thumbnail/".$file->name;

                    //If file already have in another folder.
                    if ($file->folder_id) {
                        if ($folder = Folder::find($file->folder_id)) {
                            $targetDir = "$rootDir/".$folder->name;
                            $file_with_current_dir = "$targetDir/".$file->name;
                            $thumbnail_file_with_current_dir = "$targetDir/thumbnail/".$file->name;
                        }
                    }

                    //check the file exist or not on the target folder.
                    if (file_exists($file_with_current_dir)) {

                        $file_with_target_dir = "$rootDir/".$file->name;
                        $thumbnail_file_with_target_dir = "$rootDir/thumbnail/".$file->name;
                        $file->folder_id = null;

                        //If user have any requested folder.
                        if ($request->distination) {

                            if (in_array($request->distination, $this->fileCategories())) {
                                $file->category = $request->distination;
                            }
                            elseif ($folder = Folder::find($request->distination)) {

                                if ($folder->profile_id != $request->profile->id) {
                                    return response()->json($this->structure(false, 'Folder not found!'), 200);
                                }

                                $targetDir = "$rootDir/".$folder->name;
                                $targetThumbnailDir = "$targetDir/thumbnail";
                                if (!(File::isDirectory($targetDir))) {
                                    File::makeDirectory($targetDir, 0777, true, true);
                                }
                                if (!(File::isDirectory($targetThumbnailDir))) {
                                    File::makeDirectory($targetThumbnailDir, 0777, true, true);
                                }

                                $file_with_target_dir = "$targetDir/".$file->name;
                                $thumbnail_file_with_target_dir = "$targetDir/thumbnail/".$file->name;
                                $file->folder_id = $folder->id;
                                $file->category = $folder->belongs_to;
                            }
                        }

                        try {

                            if ($file_with_current_dir != $file_with_target_dir) {

                                $file_name = pathinfo($file->name, PATHINFO_FILENAME);
                                $ext = pathinfo($file->name, PATHINFO_EXTENSION);

                                //Change the file name, If file exist on target folder.
                                if (file_exists($file_with_target_dir) || file_exists($thumbnail_file_with_target_dir)) {

                                    $file->name = $file_name.'_copy_'.date('ymdhis').".$ext";
                                    $file_with_target_dir = "$targetDir/".$file->name;

                                    $thumbnail_file_with_target_dir = "$targetDir/thumbnail/".$file->name;
                                }
                                rename($file_with_current_dir, $file_with_target_dir);

                                if ($ext != 'pdf') {
                                    if (file_exists($thumbnail_file_with_current_dir)) {
                                        rename($thumbnail_file_with_current_dir, $thumbnail_file_with_target_dir);
                                    }else{
                                        $this->resizeImage($file_with_target_dir, $thumbnail_file_with_target_dir);
                                    }
                                }
                            }

                            if ($file->save()) {
                                return response()->json($this->structure(true, 'File moved!'), 200);
                            }
                        } catch (\Exception $e) {
                            return response()->json($this->structure(false, 'File not moved!'), 200);                        
                        }
                    }
                }
            }
            return response()->json($this->structure(false, 'File not found!'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function copy(Request $request)
    {
       $validator = Validator::make($request->all(), [
            'file_id' => 'required',
            'distination' => 'nullable'
        ]);
        if ($validator->fails()) {
             return response()->json($this->structure(false, $validator->errors()->first()), 200);
        } 

        if (isset($request->profile->id)) {

            $file = FileModal::find($request->file_id);

            if ($file) {
                      
                if ($file->profile_id == $request->profile->id) {
                   
                    $folder = $this->profileFolderName($request->profile->id);
                        
                    $rootDir = $targetDir = TargetPath::common_storage($folder);
                    $file_with_current_dir = "$targetDir/".$file->name;
                    $thumbnail_file_with_current_dir = "$targetDir/thumbnail/".$file->name;

                    //If file already have in another folder.
                    if ($file->folder_id) {
                        if ($folder = Folder::find($file->folder_id)) {
                            $targetDir = "$targetDir/".$folder->name;
                            $file_with_current_dir = "$targetDir/".$file->name;
                            $thumbnail_file_with_current_dir = "$targetDir/thumbnail/".$file->name;
                        }
                    }

                    //check the file exist or not on the target folder.
                    if (file_exists($file_with_current_dir)) {

                        $file_with_target_dir = "$rootDir/".$file->name;
                        $thumbnail_file_with_target_dir = "$rootDir/thumbnail/".$file->name;

                        $fileCopy = new FileModal();
                        $fileCopy->profile_id = $file->profile_id;
                        $fileCopy->name = $file->name;
                        $fileCopy->file_type = $file->file_type;
                        $fileCopy->remarks = $file->remarks;

                        //If user have any requested folder.
                        if ($request->distination) {

                            if (in_array($request->distination, $this->fileCategories())) {
                                $fileCopy->category = $request->distination;
                            }
                            elseif ($folder = Folder::find($request->distination)) {

                                if ($folder->profile_id != $request->profile->id) {
                                    return response()->json($this->structure(false, 'Folder not found!'), 200);
                                }

                                $targetDir = "$rootDir/".$folder->name;
                                $targetThumbnailDir = "$targetDir/thumbnail";
                                if (!(File::isDirectory($targetDir))) {
                                    File::makeDirectory($targetDir, 0777, true, true);
                                }
                                if (!(File::isDirectory($targetThumbnailDir))) {
                                    File::makeDirectory($targetThumbnailDir, 0777, true, true);
                                }

                                $file_with_target_dir = $targetDir.'/'.$file->name;
                                $thumbnail_file_with_target_dir = "$targetDir/thumbnail/".$file->name;
                                $fileCopy->folder_id = $folder->id;
                                $fileCopy->category = $folder->belongs_to;
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
                                return response()->json($this->structure(true, 'File copied!'), 200);
                            }
                        } catch (\Exception $e) {
                            return response()->json($this->structure(false, 'File not copied!'), 200);                        
                        }
                    }
                }
            }
            return response()->json($this->structure(false, 'File not found!'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function delete(Request $request)
    {
        if (isset($request->profile->id)) {

            $file = FileModal::find($request->file_id);

            if ($file) {
   
                if ($file->profile_id == $request->profile->id) {
                    
                    $folder = $this->profileFolderName($request->profile->id);
                        
                    $targetDir = TargetPath::common_storage($folder);
                    $file_with_current_dir = "$targetDir/".$file->name;
                    $thumbnail_file_with_current_dir = "$targetDir/thumbnail/".$file->name;

                    //If file already have in another folder.
                    if ($file->folder_id) {
                        if ($folder = Folder::find($file->folder_id)) {
                            $file_with_current_dir = "$targetDir/".$folder->name.'/'.$file->name;
                            $thumbnail_file_with_current_dir = "$targetDir/".$folder->name.'/thumbnail/'.$file->name;
                        }
                    }

                    try {

                        //check the file exist or not on the target folder.
                        if (file_exists($file_with_current_dir)) {

                            //grant permit to modify file.
                            if(!is_writable($file_with_current_dir)){
                                chmod($file_with_current_dir, 0777);
                            }
                            unlink($file_with_current_dir);

                            if ($file->file_type == 'image') {

                                //grant permit to modify file.
                                if(!is_writable($thumbnail_file_with_current_dir)){
                                    chmod($thumbnail_file_with_current_dir, 0777);
                                }
                                unlink($thumbnail_file_with_current_dir);
                            }
                        }

                        if ($file->delete()) {

                            Share::where('access_id', $file->id)->where('access_type', 'File')->where('shared_by', $request->profile->id)->delete();
                            return response()->json($this->structure(true, 'File deleted!'), 200);
                        }
                    } catch (\Exception $e) {
                        return response()->json($this->structure(false, 'File not deleted!'), 200);                        
                    }
                }
                
            }
            return response()->json($this->structure(false, 'File not found!'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }
}
