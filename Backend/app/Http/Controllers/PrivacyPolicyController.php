<?php

namespace App\Http\Controllers;

use App\Models\CMS;

class PrivacyPolicyController extends Controller
{
    public function show()
    {
        $privacyPolicy = CMS::where('name', 'privacy-policy-page')
            ->where('is_active', 'Yes')
            ->select('content')
            ->first();

        return view('privacy-policy', [
            'cmsContent' => $privacyPolicy?->content,
            'lastUpdated' => now()->format('F j, Y'),
        ]);
    }
}
