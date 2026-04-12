<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\FileAndFolder;
use App\Models\Folder;
use App\Models\File as FileModal;
use DB;
use Illuminate\Support\Facades\Schema;

class DocsController extends Controller
{
    // Structure of response API.
    use Structure, FileAndFolder;

    // public function my(Request $request)
    // {
    //     $profile_id = $request->profile->id;
    //     if (isset($profile_id)) {

    //         $data['categories'] = $this->fileStorageOnlyCategories();
    //         $folders = Folder::where('profile_id', $profile_id)->where('belongs_to', null)->select('id', 'name', 'belongs_to', 'created_at')->get();
    //         $files = File::where('profile_id', $profile_id)->where('folder_id', null)->where('category', null)
    //                         ->select('id', 'name', 'folder_id', 'category', 'file_type', 'remarks', 'created_at')->get();

    //         $beautify = new Beautify();
    //         $data['folders'] = $beautify->folders($folders, $profile_id);
    //         $data['files'] = $beautify->files($files, $profile_id);
    //         return response()->json($this->structure(true, 'My Docs', $data), 200);
    //     }
    //     return response()->json($this->structure(false, "Profile not found!"), 200);
    // }

    public function my(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            //Folders
            $folders = Folder::where('profile_id', $profile_id)->where('belongs_to', NUll);
            if ($request->search) {
                $folders = $folders->where('name', 'like', '%' . $request->search . '%');
            }
            if ($request->sort_by == 'date') {
                $folders = $folders->orderBy('updated_at', 'desc');
            }
            if ($request->sort_by == 'name') {
                $folders = $folders->orderBy('name', 'asc');
            }
            $folders = $folders->select('id', 'name', 'belongs_to', 'created_at', DB::raw("'folder' as tag"))->get();
            
            //Files
            $files = FileModal::where('profile_id', $request->profile->id)->where('folder_id', NUll);
            if (Schema::hasColumn('files', 'category')) {
                $files = $files->where('category', NUll);
            }
            if ($request->search) {
                $files = $files->where('name', 'like', '%' . $request->search . '%');
            }
            if ($request->sort_by == 'date') {
                $files = $files->orderBy('updated_at', 'desc');
            }
            if ($request->sort_by == 'name') {
                $files = $files->orderBy('name');
            }

            //Page Calculations.
            $data_records['pagination'] = true;
            $data_records['page'] = request('page') ? intval(request('page')) : 1 ;
            $data_records['limit'] = request('limit') ? request('limit') : 6 ;
            $data_records['start'] = $data_records['page'] == 1 ? 0 : ($data_records['page'] -1 ) * $data_records['limit'] ;

            //count the total lead data.
            $data_records['total_records'] = $files->count();

            $fileSelect = ['id', 'name', 'folder_id', 'file_type', 'remarks', 'created_at', DB::raw("'file' as tag")];
            if (Schema::hasColumn('files', 'category')) {
                $fileSelect[] = 'category';
            } else {
                $fileSelect[] = DB::raw("NULL as category");
            }

            $files = $files->skip($data_records['start'])->take($data_records['limit'])
                        ->addSelect($fileSelect)
                        ->with('folder')->orderBy('updated_at')->get();

            $beautify = new Beautify();
            $folders = $beautify->folders($folders, $profile_id);
            $files = $beautify->files($files, $profile_id);

            if ($request->search || $request->folder || $request->category) {
                $data['data'] = array_merge($folders, $files);
            }else{
                $categories = $this->fileStorageOnlyCategories();
                $data['data'] = array_merge($categories, array_merge($folders, $files));
            }

            $data['data_records'] = $data_records;
            return response()->json($this->structure(true, "Folders & Files", $data), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

} //Class End Tag.
