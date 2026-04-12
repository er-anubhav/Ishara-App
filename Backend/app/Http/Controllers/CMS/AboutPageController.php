<?php

namespace App\Http\Controllers\CMS;

use App\Http\Controllers\Controller;
use App\Models\CMS;
use App\Library\Structure;
use Illuminate\Http\Request;

class AboutPageController extends Controller
{
    use Structure;

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('cms.about');
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
        $data = [
                    'name' => 'about-page',
                    'content' => $request->content,
                ];

        if ($about = CMS::where('name', 'about-page')->first()) {
            $about->content = $request->content;
            $about->created_at = date('Y-m-d H:i:s');

            if ($about->save()) {
                return response()->json($this->structure(true, "Page Updated Successfully!"), 200);
            }

        }else{
            $data['updated_at'] = date('Y-m-d H:i:s');

            if (CMS::create($data)) {
                return response()->json($this->structure(true, "Page Updated Successfully!"), 200);
            }
        }
        return response()->json($this->structure(false, "Something went wrong, Try again!"), 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\CMS  $cMS
     * @return \Illuminate\Http\Response
     */
    public function show(CMS $cMS)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\CMS  $cMS
     * @return \Illuminate\Http\Response
     */
    public function edit(CMS $cMS)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\CMS  $cMS
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, CMS $cMS)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\CMS  $cMS
     * @return \Illuminate\Http\Response
     */
    public function destroy(CMS $cMS)
    {
        //
    }
}
