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

    public function geocode(Request $request)
    {
        $search = $request->place_id ? $request->place_id : '';
        
        $url = "https://maps.googleapis.com/maps/api/geocode/json?place_id=$search&sensor=true%20&key=AIzaSyBVWipdz-2oNgj01qhoAS5WOm7gZV5yGs4";
        $curl = curl_init();

        curl_setopt_array($curl, array(
          CURLOPT_URL => $url,
          CURLOPT_RETURNTRANSFER => true,
          CURLOPT_ENCODING => '',
          CURLOPT_MAXREDIRS => 10,
          CURLOPT_TIMEOUT => 0,
          CURLOPT_FOLLOWLOCATION => true,
          CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
          CURLOPT_CUSTOMREQUEST => 'GET',
        ));

        $response = curl_exec($curl);

        curl_close($curl);
        return $response;
    }

    public function place(Request $request)
    {
        $search = $request->place ? $request->place : '';
        $search = preg_replace("/[\s_]/", "+", $search);
        
        $curl = curl_init();
        curl_setopt_array($curl, array(
          CURLOPT_URL => 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='.$search.'&types=establishment&radius=10&key=AIzaSyAaq-CLNOFfMMtll9c3LV2wpFTITExbud4',
          CURLOPT_RETURNTRANSFER => true,
          CURLOPT_ENCODING => '',
          CURLOPT_MAXREDIRS => 10,
          CURLOPT_TIMEOUT => 0,
          CURLOPT_FOLLOWLOCATION => true,
          CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
          CURLOPT_CUSTOMREQUEST => 'GET',
        ));

        $response = curl_exec($curl);

        curl_close($curl);
        return $response;
    }
}
