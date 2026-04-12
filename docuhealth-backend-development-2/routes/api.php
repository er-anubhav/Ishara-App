<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\RegisterController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\API\CMSController;
use App\Http\Controllers\API\BlogController;
use App\Http\Controllers\API\DataController;
use App\Http\Controllers\API\FolderController;
use App\Http\Controllers\API\FileController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::prefix('v1/')->group(function(){ 

    //Without auth routes.  
    Route::post('login', [AuthController::class, 'login']);
    Route::post('verify/otp', [AuthController::class, 'verify']);

    //CMS
    Route::get('cms/about', [CMSController::class, 'about']);
    Route::get('cms/contact-us', [CMSController::class, 'contact_us']);
    Route::get('cms/privacy-policy', [CMSController::class, 'privacy_policy']);

    //Blog
    Route::get('blogs', [BlogController::class, 'blogs']);

    //Home page
    Route::get('banners', [DataController::class, 'banners']);

    //With auth routes.
    Route::group(['middleware' => 'token.validate'], function(){

        Route::post('register', [RegisterController::class, 'register']);
        Route::post('profile-login', [AuthController::class, 'profile_login']);
        Route::post('logout', [AuthController::class, 'logout']);
        Route::post('logout-all-device', [AuthController::class, 'logoutFromAllDevice']);
    });

    //With profile auth routes.
    Route::group(['middleware' => 'profile.validate'], function(){

        // Route::any('email-verification-request', 'API\RegisterController@email_verification_request');

        //Profile APIs
        Route::get('profiles', [ProfileController::class, 'profiles']);
        Route::get('profile/get', [ProfileController::class, 'my_profile']);
        Route::post('profile/create', [ProfileController::class, 'create_profile']);
        Route::post('profile/update', [ProfileController::class, 'update_profile']);
        Route::post('profile/update/icon', [ProfileController::class, 'update_profile_icon']);
        Route::post('profile/update/current-location', [ProfileController::class, 'update_current_location']);

        //Promotions APIs
        Route::get('notifications', [DataController::class, 'notifications']);

        //Folders & Files
        Route::post('folder/create', [FolderController::class, 'store']);
        Route::get('folder/get', [FolderController::class, 'get']);
        Route::post('file/uploader', [FileController::class, 'file_uploader']);
        Route::post('file', [FileController::class, 'store']);
        Route::get('file/get', [FileController::class, 'get']);
    });

});