<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\Folder;
use App\Models\Share;
use App\Library\Beautify;
use App\Library\Structure;
use App\Library\TargetPath;
use App\Library\DisplayPath;
use App\Library\FileAndFolder;
use Validator;
use File;

class FolderController extends Controller
{
    use Structure, FileAndFolder;

    public function store(Request $request){

        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required|String|max:255',
              'belongs_to' => 'nullable',
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        if ($request->belongs_to) {
            if (!in_array($request->belongs_to, $this->fileCategories())) {
                return response()->json($this->structure(false, "Category to not recognized!"), 200);
            }
        }

        if($profile = UserProfile::find($request->profile->id)){

            $folder = Folder::where('profile_id', $profile->id)->where('name', $request->name);

            if ($request->belongs_to) {
                $folder = $folder->where('belongs_to', $request->belongs_to);
            }
            
            if ($folder->first()) {
               return response()->json($this->structure(false, "This destination already contains a folder name '".$request->name."'"), 200);
            }

            $myFolder = $this->profileFolderName($request->profile->id);
            $targetDir = TargetPath::common_storage(("$myFolder/".$request->name));
            if (!(File::isDirectory($targetDir))) {
                File::makeDirectory($targetDir, 0777, true, true);
            }

            $folder = new Folder();

            $folder->profile_id = $profile->id;
            $folder->name = $request->name;
            $folder->belongs_to = $request->belongs_to;

            if ($folder->save()) {
                return response()->json($this->structure(true, 'Folder Created Successfully!', $folder), 200);
            }
            return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function get(Request $request)
    {
        if(isset($request->profile->id)){

            $folder = Folder::where('profile_id', $request->profile->id);

            //Filters
            if ($request->category) {
                $folder = $folder->where('belongs_to', $request->category);
            }
            if ($request->sort_by == 'date') {
                $folders = $folder->orderBy('updated_at');
            }
            if ($request->sort_by == 'name') {
                $folders = $folder->orderBy('name');
            }

            if ($folders = $folder->select('id', 'name', 'belongs_to', 'created_at')->get()) {
                $beautify = new Beautify();
                $folders = $beautify->folders($folders, $request->profile->id);
                return response()->json($this->structure(true, 'Folders', $folders), 200);
            }
            return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function rename(Request $request)
    {
       $validator = Validator::make($request->all(), [
            'folder_id' => 'required',
            'name' => 'nullable|string|max:25'
        ]);
        if ($validator->fails()) {
             return response()->json($this->structure(false, $validator->errors()->first()), 200);
        } 

        if (isset($request->profile->id)) {

            $folder = Folder::find($request->folder_id);

            if ($folder) {
                    
                if ($folder->profile_id == $request->profile->id) {
                    
                    $myFolder = $this->profileFolderName($request->profile->id);
                    $currentDir = TargetPath::common_storage(("$myFolder/".$folder->name));
                    $targetDir = TargetPath::common_storage(("$myFolder/".$request->name));

                    if (File::isDirectory($currentDir)) {
                        File::moveDirectory($currentDir, $targetDir);
                    }else{
                        File::makeDirectory($targetDir, 0777, true, true);
                    }

                    $folder->name = $request->name;
                    $folder->updated_at = date('Y-m-d H:i:s');
                    if ($folder->save()) {
                        return response()->json($this->structure(true, 'Folder renamed!'), 200);
                    }
                }
            }
            return response()->json($this->structure(false, 'Folder not found!'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function delete(Request $request)
    {
        if (isset($request->profile->id)) {

            $profile_id = $request->profile->id;
            $folder = Folder::find($request->folder_id);

            if ($folder) {
                    
                if ($folder->profile_id == $profile_id) {
                    
                    $myFolder = $this->profileFolderName($profile_id);
                    $currentDir = TargetPath::common_storage(("$myFolder/".$folder->name));

                    if (File::isDirectory($currentDir)) {
                        File::deleteDirectory($currentDir);
                    }

                    if ($folder->delete()) {

                        Share::where('access_id', $folder->id)->where('access_type', 'Folder')->where('shared_by', $profile_id)->delete();
                        $files = $folder->files;

                        foreach ($files as $file) {
                            if ($file->delete()) {
                                Share::where('access_id', $file->id)->where('access_type', 'File')->where('shared_by', $profile_id)->delete();
                            }
                        }

                        return response()->json($this->structure(true, 'Folder deleted!'), 200);
                    }
                }
            }
            return response()->json($this->structure(false, 'Folder not found!'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    //folder can move only categories.
    public function move(Request $request)
    {
        if (isset($request->profile->id)) {

            $folder = Folder::find($request->folder_id);

            if ($folder) {
                    
                if ($folder->profile_id == $request->profile->id) {
                    
                    $folder->belongs_to = null;

                    if ($request->destination) {
                        if (!in_array($request->destination, $this->fileCategories())) {
                            return response()->json($this->structure(false, "Category not recognized!"), 200);
                        }
                        $folder->belongs_to = $request->destination;
                    }

                    $files = $folder->files;
                    
                    foreach ($files as $key => $value) {
                        $value->category = $folder->belongs_to;
                        $value->save();
                    }

                    if ($folder->save()) {
                        return response()->json($this->structure(true, 'Folder moved!'), 200);
                    }
                }
            }
            return response()->json($this->structure(false, 'Folder not found!'), 200);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }
}
