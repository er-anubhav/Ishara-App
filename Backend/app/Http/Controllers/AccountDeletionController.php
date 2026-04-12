<?php

namespace App\Http\Controllers;

use App\Models\AccountDeletionRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AccountDeletionController extends Controller
{
    public function show()
    {
        return view('account-deletion');
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'nullable|string|max:100',
            'email' => 'nullable|email|max:255',
            'phone' => 'nullable|string|max:30',
            'message' => 'nullable|string|max:1000',
        ]);

        $validator->after(function ($validator) use ($request) {
            if (!filled($request->email) && !filled($request->phone)) {
                $validator->errors()->add(
                    'contact',
                    'Enter either your email address or phone number so we can identify your account.'
                );
            }
        });

        if ($validator->fails()) {
            return redirect()
                ->route('account-deletion.show')
                ->withErrors($validator)
                ->withInput();
        }

        AccountDeletionRequest::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'message' => $request->message,
            'status' => 'pending',
            'requested_at' => now(),
        ]);

        return redirect()
            ->route('account-deletion.show')
            ->with('success', 'Your account deletion request has been submitted. Our team will review it and contact you if more details are needed.');
    }
}
