<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Library\Structure;
use App\Library\Beautify;
use App\Models\File as FileModal;

class HomeController extends Controller
{
    // Structure of response API.
    use Structure;

    public function recent_uploads(Request $request){

        if(isset($request->profile->id)){

            $file = FileModal::where('profile_id', $request->profile->id);

            if ($request->category) {
                $file = $file->where('category', $request->category);
            }

            if ($request->folder) {
                $file = $file->where('folder_id', $request->folder);
            }

            if ($files = $file->select('id', 'name', 'folder_id', 'category', 'file_type', 'remarks', 'created_at')->with('folder')->orderBy('id', 'desc')->limit(20)->get()) {

                $beautify = new Beautify();
                $files = $beautify->files($files, $request->profile->id);
                return response()->json($this->structure(true, 'Recent Files', $files), 200);
            }
            return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }
}
