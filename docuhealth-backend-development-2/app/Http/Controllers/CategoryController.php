<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Library\DisplayPath;
use App\Library\TargetPath;
use App\Library\Structure;
use Illuminate\Http\Request;
use Validator;

class CategoryController extends Controller
{
    use Structure;

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('categories');
    }

    public function data(Request $request){

        $data = Category::orderBy('id', 'desc')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {
            
            $button = '<div class="btn-group"><a href="javascript:void()" name="delete" data-value="'.$data->id.'" class="btn btn-sm btn-danger delete-btn"><i class="bx bx-trash"></i></a>';

            if($data->is_active == 'Yes'){
                $button .= '<div class="btn-group"><a href="javascript:void()" name="disable" data-value="'.$data->id.'" class="btn btn-sm btn-danger status-btn"><i class="bx bx-block"></i></a>';
            }else{
                $button .= '<div class="btn-group"><a href="javascript:void()" name="enable" data-value="'.$data->id.'" class="btn btn-sm btn-secondary status-btn"><i class="bx bx-check"></i></a>';
            }

            $button .= '</div>';

            return $button;
        })->addColumn('icon', function ($data) {

            if($data->icon){
                $img_with_url = DisplayPath::category_icon().'/'.$data->icon;
                return  '<a href="'.$img_with_url.'" target="_BLANK"><img src="'.$img_with_url.'" style="width:80px; height:60px;"/></a>';
            }
            $img_with_url = url("/app-assets/images/icon/no-image.png");
            return  '<img src="'.$img_with_url.'" style="width:80px; height:60px;"/>';
        })->addColumn('status', function ($data) {
            if ($data->is_active == 'Yes') {
                return '<span class="badge badge-light-info">Active</span>';
            }
            return '<span class="badge badge-light-danger">In-Active</span>';
        })->setRowClass(function ($user) {
                    return 'category-edit-btn';
        })->setRowAttr([
            'style' => 'cursor:pointer;',
            'data-value' => '{{$id}}|{{$name}}|{{$position}}',
        ])->rawColumns(['action', 'icon', 'status'])->make(true);

    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required',  
              'position' => 'required|numeric|min:0',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $file_name = NULL;
        if ($request->file('icon') != "") {

            $file_type = $_FILES['icon']["type"];
            $file = $request->file('icon');
            $ext = preg_replace('/^.*\.([^.]+)$/D', '$1', $file->getClientOriginalName());
            //Make directory, If doesn't exist.
            $targetDir = TargetPath::category_icon();
            if (!(File::isDirectory($targetDir))) {

                File::makeDirectory($targetDir, 0777, true, true);
            }
            $file_name = date('ymdhis').'_CATEGORY.'.$ext;

            $file->move($targetDir, $file_name);
        }

        $data = [
                'icon' => $file_name,
                'name' => $request->name,
                'position' => $request->position,
                'created_at' => date('Y-m-d h:i:s'),
            ];

        if (Category::create($data)) {
            return response()->json($this->structure(true, 'Category Added Successfully!'), 200);
        }

        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Category  $category
     * @return \Illuminate\Http\Response
     */
    public function show(Category $category)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Category  $category
     * @return \Illuminate\Http\Response
     */
    public function edit(Category $category)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Category  $category
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Category $category)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required',  
              'position' => 'required|numeric|min:0',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }
      
        $data = [
                'name' => $request->name,
                'position' => $request->position,
                'updated_at' => date('Y-m-d h:i:s'),
            ];

        if ($request->file('icon') != "") {

            if(!$this->isValidImageFile($request->file('icon'))) 
                    return response()->json($this->structure(false, "Invalid Image File Format!"), 200);
                
            $file_type = $_FILES['icon']["type"];
            $file = $request->file('icon');
            $ext = preg_replace('/^.*\.([^.]+)$/D', '$1', $file->getClientOriginalName());
            //Make directory, If doesn't exist.
            $targetDir = TargetPath::category_icon();
            if (!(File::isDirectory($targetDir))) {

                File::makeDirectory($targetDir, 0777, true, true);
            }
            $file_name = date('ymdhis').'_CATEGORY.'.$ext;

            $file->move($targetDir, $file_name);

            $data['icon'] = $file_name;
        }
            
        if (Category::where('id', $request->category_id)->update($data)) {
            return response()->json($this->structure(true, 'Category Updated Successfully!'), 200);
        }
        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Category  $category
     * @return \Illuminate\Http\Response
     */
    public function destroy(Category $category)
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
        $response = Category::where('id', $request->id)->update($data);

        if ($response > 0) {
            if ($request->status == 'delete') {
              return response()->json(['error' => false, 'message' => 'Deleted Succesfully!']);
            }
            return response()->json(['error' => false, 'message' =>'Status Updated Succesfully!']);
        }
        return response()->json(['error'=> true, 'message' => 'Somthing went wrong, try again !']);
    }
}
