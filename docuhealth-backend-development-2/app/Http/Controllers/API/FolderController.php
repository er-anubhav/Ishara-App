<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\Folder;
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
              'belongs_to' => 'required',
            ], ['belongs_to.required' => 'Category to not recognized!']);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        if (!in_array($request->belongs_to, $this->fileCategories())) {
            return response()->json($this->structure(false, "Category to not recognized!"), 200);
        }

        if($profile = UserProfile::find($request->profile->id)){

            if (Folder::where('profile_id', $profile->id)->where('belongs_to', $request->belongs_to)->where('name', $request->name)->first()) {
               return response()->json($this->structure(false, "This destination already contains a folder name '".$request->name."'"), 200);
            }

            $folder = new Folder();

            $folder->profile_id = $profile->id;
            $folder->name = $request->name;
            $folder->belongs_to = $request->belongs_to;
            $folder->created_at = date('Y-m-d h:i:s');

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

            if ($request->category) {
                $folder = $folder->where('belongs_to', $request->category);
            }

            if ($folder = $folder->select('id', 'name', 'belongs_to')->get()) {
                return response()->json($this->structure(true, 'Folders', $folder), 200);
            }
            return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }
}
