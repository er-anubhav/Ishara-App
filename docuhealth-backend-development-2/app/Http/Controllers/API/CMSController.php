<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\CMS;
use App\Library\Structure;
use App\Library\Beautify;

class CMSController extends Controller
{
    use Structure;

    public function about(Request $request)
    {
        $about = CMS::where('name', 'about-page')->where('is_active', 'Yes')->select('name', 'content', 'tags')->first();

        if ($about) {
            return response()->json($this->structure(true, "", $about), 200);
        }

        return response()->json($this->structure(false, "Content not found!"), 200);
    }

    public function contact_us(Request $request)
    {
        $contact_us = CMS::where('name', 'contact-us-page')->where('is_active', 'Yes')->select('name', 'content', 'tags')->first();

        if ($contact_us) {
            return response()->json($this->structure(true, "", $contact_us), 200);
        }

        return response()->json($this->structure(false, "Content not found!"), 200);
    }

    public function privacy_policy(Request $request)
    {
        $privacy_policy = CMS::where('name', 'privacy-policy-page')->where('is_active', 'Yes')->select('name', 'content', 'tags')->first();

        if ($privacy_policy) {
            return response()->json($this->structure(true, "", $privacy_policy), 200);
        }

        return response()->json($this->structure(false, "Content not found!"), 200);
    }
}
