<?php

namespace App\Http\Controllers;

use App\Models\Tag;
use App\Library\Structure;
use Validator;
use Illuminate\Http\Request;

class TagsController extends Controller
{
    use Structure;

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('tags');
    }

    public function data(Request $request){

        $data = Tag::orderBy('id', 'desc')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {
            
            return '<a href="javascript:void()" name="delete" data-value="'.$data->id.'" class="btn btn-sm btn-danger status-btn"><i class="bx bx-trash"></i></a>';
        })->setRowClass(function ($user) {
                    return 'tag-edit-btn';
        })->setRowAttr([
            'style' => 'cursor:pointer;',
            'data-value' => '{{$id}}|{{$name}}',
        ])->rawColumns(['action'])->make(true);
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
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $data = [
                'name' => $request->name,
                'created_at' => date('Y-m-d h:i:s'),
            ];

        if (Tag::create($data)) {
            return response()->json($this->structure(true, 'Tag Added Successfully!'), 200);
        }

        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Tag  $tag
     * @return \Illuminate\Http\Response
     */
    public function show(Tag $tag)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Tag  $tag
     * @return \Illuminate\Http\Response
     */
    public function edit(Tag $tag)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Tag  $tag
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Tag $tag)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }
      
        $data = [
                'name' => $request->name,
                'updated_at' => date('Y-m-d h:i:s'),
            ];

        if (Tag::where('id', $request->tag_id)->update($data)) {
            return response()->json($this->structure(true, 'Tags Updated Successfully!'), 200);
        }
        return response()->json($this->structure(false, "No Changes!"), 200);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Tag  $tag
     * @return \Illuminate\Http\Response
     */
    public function destroy(Tag $tag)
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
        $response = Tag::where('id', $request->id)->update($data);

        if ($response > 0) {
            if ($request->status == 'delete') {
              return response()->json(['error' => false, 'message' => 'Deleted Succesfully!']);
            }
            return response()->json(['error' => false, 'message' =>'Status Updated Succesfully!']);
        }
        return response()->json(['error'=> true, 'message' => 'Somthing went wrong, try again !']);
    }
}
