<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Banner;
use App\Library\Structure;
use App\Library\DisplayPath;
use App\Library\TargetPath;
use Validator;
use File;
use Auth;

class BannerController extends Controller
{
    use Structure;

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index(Request $request)
    {
        return view('banners');
    }

    /**
     * Show the data table a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function data(Request $request)
    {
        $data = Banner::orderBy('position', 'asc')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {
            if ($data->is_active == 'Yes') {
                $button = '<a href="javascript:void()" name="disable" data-value="'.$data->id.'" class="btn btn-sm btn-danger status-btn"><i class="bx bx-block"></i></a>';
            }else{
                $button = '<a href="javascript:void()" name="enable" data-value="'.$data->id.'" class="btn btn-sm btn-success status-btn"><i class="bx bx-check"></i></a>';
            }
            return $button;
        })->addColumn('image', function ($data) {
            $img_with_url = DisplayPath::banner().$data->image;
            return  '<a href="javascript:void();" data-value="'.$img_with_url.'" class="image-view"><img src="'.$img_with_url.'" style="width:80px; height:60px;"/></a>';
        })->addColumn('status', function ($data) {
            if ($data->is_active == 'Yes') {
                return '<span class="badge badge-light-info">Active</span>';
            }
            return '<span class="badge badge-light-danger">In-Active</span>';
        })->setRowClass(function ($user) {
                    return 'banner-edit-btn';
        })->setRowAttr([
            'style' => 'cursor:pointer;',
            'data-value' => '{{$id}}|{{$position}}|{{$url}}|{{$image}}',
        ])->rawColumns(['action', 'image', 'status'])->make(true);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $error_msg = ['banner_image.max' => 'Image may not be greater than 2 MB.'];
        $validator = Validator::make($request->all(), 
            [ 
              'banner_image' => 'required|file|mimes:gif,jpg,bmp,png,jpeg,pjpeg|max:2048',
              'banner_position' => 'required|numeric',  
            ], $error_msg);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $image_id = 0;
        if ($request->file('banner_image') != "") {

            $file_type = $_FILES['banner_image']["type"];
            $file = $request->file('banner_image');
            $ext = preg_replace('/^.*\.([^.]+)$/D', '$1', $file->getClientOriginalName());
            //Make directory, If doesn't exist.
            $targetDir = TargetPath::banner();
            if (!(File::isDirectory($targetDir))) {

                File::makeDirectory($targetDir, 0777, true, true);
            }
            $file_name = date('ymdhis').'_BANNER.'.$ext;

            $file->move($targetDir, $file_name);
            
            $data = [
                'image' => $file_name,
                'type' => 'slider',
                'position' => $request->banner_position,
                'url' => $request->banner_url,
                'url_type' => 'slug',
                'remarks' => '',
                'created_at' => date('Y-m-d h:i:s'),
            ];

            //URL validation.
            if (preg_match("/\b(?:(?:https?|ftp):\/\/|www\.)[-a-z0-9+&@#\/%?=~_|!:,.;]*[-a-z0-9+&@#\/%=~_|]/i", $request->banner_url)) {
                $data['url_type'] = 'link';
            }

            if (Banner::create($data)) {
                return response()->json($this->structure(true, 'Banner Added Successfully!'), 200);
            }
        }
        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $error_msg = ['banner_image.max' => 'Image may not be greater than 2 MB.'];
        $validator = Validator::make($request->all(), 
            [ 
              'banner_image' => 'nullable|max:2048',
              'banner_position' => 'required|numeric',  
            ], $error_msg);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }
      
        $data = [
                'type' => 'slider',
                'position' => $request->banner_position,
                'url' => $request->banner_url,
                'url_type' => 'slug',
                'remarks' => '',
                'updated_at' => date('Y-m-d h:i:s'),
            ];

        if ($request->file('banner_image') != "") {

            if(!$this->isValidImageFile($request->file('banner_image'))) 
                    return response()->json($this->structure(false, "Invalid Image File Format!"), 200);
                
            $file_type = $_FILES['banner_image']["type"];
            $file = $request->file('banner_image');
            //Make directory, If doesn't exist.
            $targetDir = TargetPath::banner();
            if (!(File::isDirectory($targetDir))) {

                File::makeDirectory($targetDir, 0777, true, true);
            }
            $file_name = date('ymdhis').'_BANNER';

            $file->move($targetDir, $file_name);

            $data['image'] = $file_name;
        }
            
        //URL validation.
        if (preg_match("/\b(?:(?:https?|ftp):\/\/|www\.)[-a-z0-9+&@#\/%?=~_|!:,.;]*[-a-z0-9+&@#\/%=~_|]/i", $request->banner_url)) {
            $data['url_type'] = 'link';
        }

        if (Banner::where('id', $request->banner_id)->update($data)) {
            return response()->json($this->structure(true, 'Banner Updated Successfully!'), 200);
        }
        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }
    
    private function isValidImageFile($files = [])
    {
        //allowed image type of product images.
        $allowedFileExt = ['jpg','png', 'jpeg', 'GIF'];

        if (!empty($files) && is_array($files)) {

            foreach ($files as $file) {

                $extension = $file->getClientOriginalExtension();

                if(!in_array($extension, $allowedFileExt)) 
                    return false;
            }
            return true;
        }elseif (!empty($files)) {

            $extension = $files->getClientOriginalExtension();
           
            return (in_array($extension, $allowedFileExt)) ? true : false ;

        }
        return false;
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
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
        $response = Banner::where('id',$request->id)->update($data);

        if ($response > 0) {
            if ($request->status == 'delete') {
              return response()->json(['error' => false, 'message' => 'Deleted Succesfully!']);
            }
            return response()->json(['error' => false, 'message' =>'Status Updated Succesfully!']);
        }
        return response()->json(['error'=> true, 'message' => 'Somthing went wrong, try again !']);
    }

}
