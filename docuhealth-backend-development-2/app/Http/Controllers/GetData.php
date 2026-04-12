<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Specialization;
use App\Models\CMS;
use App\Library\Structure;

class GetData extends Controller
{
    use Structure;

    public function specializations(Request $request)
    {
        $data = Specialization::all();

        return response()->json($this->structure(true, '', $data), 200);
    }

    public function cms(Request $request)
    {
        $data = [];

        if ($request->name) {
            $data = CMS::where('name', $request->name)->first();
        }else{
            $data = CMS::all();
        }

        return response()->json($this->structure(true, '', $data), 200);
    }
}
