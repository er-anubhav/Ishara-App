<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Library\Structure;
use App\Library\ObjConverter;
use App\Models\UserProfile;

class EnsureProfileTokenIsValid
{
    // Structure of response API.
    use Structure, ObjConverter;

    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        $profile = isset(auth('api')->payload()['logged_in_profile']) ? auth('api')->payload()['logged_in_profile'] : [] ;
        if(!empty($profile))
        {
            $request->profile = $this->objConvert($profile);
            return $next($request);
        }
        return response()->json($this->structure(false, "Unauthorised profile access"), 200);
    }
}
