<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Bookmark;
use App\Models\File;
use App\Models\Folder;
use App\Library\Structure;
use App\Library\Beautify;
use Validator;
use DB;

class BookmarkController extends Controller
{
    
    // Structure of response API.
    use Structure;

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id' => 'required',
            'type' => 'required',
        ]);
        if ($validator->fails()) {
            return response()->json($this->structure(false, 'Something went wrong!'), 200);
        }

        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            $requested_file_type = ucfirst($request->type);
            if (Bookmark::where(['profile_id' => $profile_id, 'asset_id' => $request->id, 'asset_type' => $requested_file_type])->first()) {
                return response()->json($this->structure(false, 'Already added!'), 200);
            }
            
            if ($requested_file_type == 'File') {
                
                if ($file = File::find($request->id)) {
                    
                    if ($file->profile_id != $profile_id) {
                        return response()->json($this->structure(false, 'File not found!'), 200);
                    }

                    $bookmark = new Bookmark();
                    $bookmark->profile_id = $profile_id;
                    $bookmark->asset_id = $file->id;
                    $bookmark->asset_type = $requested_file_type;
                    $bookmark->created_at = date('Y-m-d H:i:s');

                    try {
                        $bookmark->save();
                        return response()->json($this->structure(true, 'Added to bookmark.'), 200);
                    } catch (\Exception $e) {
                        return response()->json($this->structure(false, 'Something went wrong!!'), 200);
                    }
                }
            }elseif ($requested_file_type == 'Folder') {
                
                if ($folder = Folder::find($request->id)) {

                    if ($folder->profile_id != $profile_id) {
                        return response()->json($this->structure(false, 'Folder not found!'), 200);
                    }

                    $bookmark = new Bookmark();
                    $bookmark->profile_id = $profile_id;
                    $bookmark->asset_id = $folder->id;
                    $bookmark->asset_type = $requested_file_type;
                    $bookmark->created_at = date('Y-m-d H:i:s');

                    try {
                        $bookmark->save();
                        return response()->json($this->structure(true, 'Added to bookmark.'), 200);
                    } catch (\Exception $e) {
                        return response()->json($this->structure(false, 'Something went wrong!!'), 200);
                    }
                }
            }

            return response()->json($this->structure(false, 'Something went wrong!'), 200);
        }

        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function remove(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id' => 'required',
            'type' => 'required',
        ]);
        if ($validator->fails()) {
            return response()->json($this->structure(false, 'Something went wrong!'), 200);
        }

        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            $requested_file_type = ucfirst($request->type);
            if ($bookmark = Bookmark::where(['profile_id' => $profile_id, 'asset_id' => $request->id, 'asset_type' => $requested_file_type])->first()) {
                try {
                    $bookmark->delete();
                    return response()->json($this->structure(true, 'Remove from bookmark.'), 200);
                } catch (\Exception $e) {
                    return response()->json($this->structure(false, 'Something went wrong!!'), 200);
                }
            }
            return response()->json($this->structure(false, "$requested_file_type not found!"), 200); 
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

    public function get(Request $request)
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
                //FOlders___
                $folders = Bookmark::leftJoin('folders as f', 'f.id', 'bookmarks.asset_id')->where(['bookmarks.profile_id' => $profile_id, 'bookmarks.asset_type' => 'Folder'])
                        ->where('f.deleted_at', null)->select('bookmarks.id', 'f.id as folder_id', 'f.name', 'f.belongs_to', 'f.created_at', DB::raw("'folder' as tag"));

                if ($request->search) 
                    $folders = $folders->where('f.name', 'like', '%' . $request->search . '%');
                
                if ($request->sort_by == 'date')
                    $folders = $folders->orderBy('bookmarks.created_at', 'desc');

                if ($request->sort_by == 'name')
                    $folders = $folders->orderBy('f.name', 'ASC');

                $folders = $folders->get()->toArray();
            }

            //FIles____
            $files = Bookmark::leftJoin('files as f', function ($join)
                                {
                                    $join->on('f.id', '=', 'bookmarks.asset_id')->where('f.deleted_at', null);
                                })
                                ->leftJoin('folders as fd', function ($join)
                                {
                                    $join->on('fd.id', '=', 'f.folder_id')->where('fd.deleted_at', null);
                                })
                                ->where(['bookmarks.profile_id' => $profile_id, 'bookmarks.asset_type' => 'File']);

            if ($request->search) 
                $files = $files->where('f.name', 'like', '%' . $request->search . '%');
            
            if ($request->sort_by == 'date')
                $files = $files->orderBy('bookmarks.created_at', 'desc');

            if ($request->sort_by == 'name')
                $files = $files->orderBy('f.name', 'ASC');

            //count the total lead data.
            $data_records['total_records'] = $files->count();

            $files = $files->skip($data_records['start'])->take($data_records['limit'])
                        ->addSelect('bookmarks.id', 'f.id as file_id', 'f.name', 'f.folder_id', 'f.category', 'f.file_type', 'f.remarks', 'f.created_at', 'fd.name as folder_name', DB::raw("'file' as tag"))
                        ->orderBy('bookmarks.created_at', 'desc')->get();

            $beautify = new Beautify();
            $files = $beautify->files($files, $profile_id, 'Bookmark');

            $data['data'] = array_merge($folders, $files);
            $data['data_records'] = $data_records;
            return response()->json($this->structure(true, "Bookmarks", $data), 200); 
        }

        return response()->json($this->structure(false, "Unauthorised profile access"), 200); 
    }

}
