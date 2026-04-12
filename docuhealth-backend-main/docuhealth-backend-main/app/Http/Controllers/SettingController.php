<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Setting;
use App\Library\Structure;
use Validator;

class SettingController extends Controller
{
    use Structure;

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('settings');
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
        //
    }

    /**
     * Show data.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function data(Request $request){

        $data = Setting::orderBy('id', 'desc')->get();

        return datatables()->of($data)->setRowClass(function ($user) {
                    return 'setting-edit-btn';
        })->setRowAttr([
            'style' => 'cursor:pointer;',
            'data-value' => '{{$id}}|{{$key}}|{{$value}}',
        ])->make(true);
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
    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'key' => 'required',  
              'value' => 'required',  
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }
      
        $data = [
                'value' => $request->value,
                'updated_at' => date('Y-m-d h:i:s'),
            ];

        if (Setting::where('id', $request->setting_id)->update($data)) {
            return response()->json($this->structure(true, 'Updated Successfully!'), 200);
        }
        return response()->json($this->structure(false, "No Changes!"), 200);
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
}
