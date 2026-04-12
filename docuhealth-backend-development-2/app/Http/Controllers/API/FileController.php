<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use App\Library\FileAndFolder;
use App\Library\DisplayPath;
use App\Library\TargetPath;
use App\Library\Structure;
use App\Models\User;
use App\Models\File as FileModal;
use App\Models\Folder;
use File;

class FileController extends Controller
{
    // Structure of response API.
    use Structure, FileAndFolder;

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
            $ext = pathinfo($file->getClientOriginalName(), PATHINFO_EXTENSION);

            //Create folder by profile or given name.
            $folder = empty($request->target_path) ? $this->profileFolderName($request->profile->id) 
                                                        : str_replace(' ', '_', strtoupper($request->target_path));
            
            $file_name = date('ymdhis')."_$folder.$ext";
            $targetDir = TargetPath::common_storage($folder);
            if (!(File::isDirectory($targetDir))) {
                File::makeDirectory($targetDir, 0777, true, true);
            }
            $file->move($targetDir, $file_name);

            $data['file'] = DisplayPath::common_storage().'/'.$folder.'/'.$file_name;
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
            'folder_id' => 'nullable|numeric',
            'remarks' => 'nullable|string',
        ]);
        if ($validator->fails()) {
             return response()->json($this->structure(false, $validator->errors()->first()), 200);
        } 

        if (isset($request->profile->id)) {
            
            $belongs_to = $response = null;
            $files = $request->files_name;

            if($request->folder_id){
                if ($folder = Folder::find($request->folder_id)) {
                    $belongs_to = $folder->belongs_to; 
                }
            }

            for ($i=0; $i < sizeof($files); $i++) { 
                
                if($files[$i]){

                    $file = new FileModal();

                    $file_type = pathinfo($files[$i], PATHINFO_EXTENSION) == 'pdf' ? 'document' : 'image' ;

                    $file->name = $files[$i];    
                    $file->profile_id = $request->profile->id;
                    $file->folder_id = $request->folder_id;
                    $file->category = $belongs_to;   
                    $file->file_type = $file_type;   
                    $file->remarks = $request->remarks;

                    $response = $file->save();    
                }
            }

            if ($response) {
                return response()->json($this->structure(true, 'Uploaded successfully'), 200);
            }
            return response()->json($this->structure(false, 'All files are not uploaded'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function get(Request $request)
    {
        if(isset($request->profile->id)){

            $file = FileModal::where('profile_id', $request->profile->id);

            if ($request->category) {
                $file = $file->where('category', $request->category);
            }

            if ($request->folder) {
                $file = $file->where('folder_id', $request->folder);
            }

            if ($files = $file->select('id', 'name', 'category', 'file_type', 'remarks', 'created_at')->get()) {

                $files = $this->beautify->files($files, $request->profile->id);
                return response()->json($this->structure(true, 'Files', $file), 200);
            }
            return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }
}
