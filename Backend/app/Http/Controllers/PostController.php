<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Category;
use App\Models\Tag;
use Illuminate\Http\Request;
use App\Library\TargetPath;
use App\Library\DisplayPath;
use App\Library\Structure;
use App\Library\GlobalFunction;
use Validator;
use File;

class PostController extends Controller
{
    use Structure, GlobalFunction;
    
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('post.index');
    }

    public function data(Request $request){

        $data = Post::orderBy('id', 'desc')->with('categoryName')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {
            
            $url = url('/admin/posts').'/'.$data->id.'/edit';
            $button = '<div class="btn-group"><a href="'.$url.'" target="_BLANK" class="edit-btn btn btn-sm btn-secondary"><i class="bx bx-edit"></i></a>';
            $button .= '<a href="javascript:void()" name="delete" data-value="'.$data->id.'" class="btn btn-sm btn-danger status-btn"><i class="bx bx-trash"></i></a></div>';

            return $button;
        })->addColumn('image', function ($data) {

            if($data->icon != NULL){
                $img_with_url = DisplayPath::category_icon().'/'.$data->image;
                return  '<a href="'.$img_with_url.'" target="_BLANK"><img src="'.$img_with_url.'" style="width:80px; height:60px;"/></a>';
            }
            $img_with_url = url("/app-assets/images/icon/no-image.png");
            return  '<img src="'.$img_with_url.'" style="width:80px; height:60px;"/>';
        })->addColumn('status', function ($data) {
            if ($data->status == 'Active') {
                return '<span class="badge badge-light-success">Active</span>';
            }
            return '<span class="badge badge-light-warning">Draft</span>';
        })->addColumn('content', function ($data) {
            return $data->content;
        })->addColumn('tags', function ($data) {
            $tags = implode(', ', json_decode($data->tags, true));
            return $tags;
        })->addColumn('category', function ($data) {
            return $data->categoryName->name;
        })->rawColumns(['action', 'image', 'status', 'content', 'category'])->make(true);

    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        $data['categories'] = Category::all();
        $data['tags'] = Tag::all();

        return view('post.create', $data);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $error_msg = ['image.max' => 'Image may not be greater than 2 MB.'];
        $validator = Validator::make($request->all(), 
            [ 
              'heading' => 'required', 
              'description' => 'required', 
              'category' => 'required', 
              'tags' => 'required', 
              'content' => 'required', 
              'image' => 'nullable|max:2048',
            ], $error_msg);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $file_name = null;
        if ($request->file('image') != "") {

            if (!$this->image_validation($request->file('image'))) {
                return response()->json($this->structure(false, 'File must be image & less than 2 MB.'), 200);
            }

            $file_type = $_FILES['image']["type"];
            $file = $request->file('image');
            $ext = preg_replace('/^.*\.([^.]+)$/D', '$1', $file->getClientOriginalName());
            //Make directory, If doesn't exist.
            $targetDir = TargetPath::blog_post();
            if (!(File::isDirectory($targetDir))) {
                File::makeDirectory($targetDir, 0777, true, true);
            }
            $file_name = date('ymdhis').'_BLOG.'.$ext;

            $file->move($targetDir, $file_name);
        }
            
        $data = [
            'image' => $file_name,
            'heading' => $request->heading,
            'description' => $request->description,
            'category' => $request->category,
            'tags' => json_encode($request->tags, true),
            'content' => $request->content,
            'status' => 'Active',
            'created_at' => date('Y-m-d h:i:s'),
        ];

        if (Post::create($data)) {
            return response()->json($this->structure(true, 'Post Added Successfully!'), 200);
        }
        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Http\Response
     */
    public function show(Post $post)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Http\Response
     */
    public function edit(Post $post)
    {
        $data['categories'] = Category::all();
        $data['tags'] = Tag::all();
        $data['post'] = $post;

        $post->image = $post->image ? DisplayPath::blog_post().'/'.$post->image : null ;

        return view('post.edit', $data);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $error_msg = ['image.max' => 'Image may not be greater than 2 MB.'];
        $validator = Validator::make($request->all(), 
            [ 
              'heading' => 'required', 
              'description' => 'required', 
              'category' => 'required', 
              'tags' => 'required', 
              'content' => 'required', 
              'image' => 'nullable|max:2048',
            ], $error_msg);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        if ($post = Post::find($request->id)) {

            $file_name = null;
            if ($request->file('image') != "") {

                if (!$this->image_validation($request->file('image'))) {
                    return response()->json($this->structure(false, 'File must be image & less than 2 MB.'), 200);
                }

                $file_type = $_FILES['image']["type"];
                $file = $request->file('image');
                $ext = preg_replace('/^.*\.([^.]+)$/D', '$1', $file->getClientOriginalName());
                //Make directory, If doesn't exist.
                $targetDir = TargetPath::blog_post();
                if (!(File::isDirectory($targetDir))) {
                    File::makeDirectory($targetDir, 0777, true, true);
                }
                $file_name = date('ymdhis').'_BLOG.'.$ext;

                $file->move($targetDir, $file_name);
                $post->image = $file_name;
            }
                
            $post->heading = $request->heading;
            $post->description = $request->description;
            $post->category = $request->category;
            $post->tags = json_encode($request->tags, true);
            $post->content = $request->content;
            $post->updated_at = date('Y-m-d h:i:s');

            if ($post->save()) {
                return response()->json($this->structure(true, 'Post Updated Successfully!'), 200);
            }
        }
        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Http\Response
     */
    public function destroy(Post $post)
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
        $response = Post::where('id', $request->id)->update($data);

        if ($response > 0) {
            if ($request->status == 'delete') {
              return response()->json(['error' => false, 'message' => 'Deleted Succesfully!']);
            }
            return response()->json(['error' => false, 'message' =>'Status Updated Succesfully!']);
        }
        return response()->json(['error'=> true, 'message' => 'Somthing went wrong, try again !']);
    }
}
