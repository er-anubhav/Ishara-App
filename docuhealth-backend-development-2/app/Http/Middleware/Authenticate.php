<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return string|null
     */
    protected function redirectTo($request)
    {
        if (! $request->expectsJson()) {
            
            $url_to_array = explode('/', url()->current());
            if (in_array('admin', $url_to_array)) {
                return route('admin.login');
            }

            elseif (in_array('sub-admin', $url_to_array)) {
                return route('sub-admin.login');            
            }

            return route('sub-admin.login');
        }
    }
}
