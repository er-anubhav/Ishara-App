<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Category;
use App\Models\Tag;
use Illuminate\Http\Request;

class PostController extends Controller
{
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

        $data = Post::orderBy('id', 'desc')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {
            
            return '<a href="javascript:void()" name="enable" data-value="'.$data->id.'" class="btn btn-sm btn-danger status-btn"><i class="bx bx-trash"></i></a>';
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
        })->rawColumns(['action', 'image', 'status'])->make(true);

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
        //
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
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Post $post)
    {
        //
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
}
