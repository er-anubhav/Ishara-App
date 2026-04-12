<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Admin\HomeController;
use App\Http\Controllers\Admin\SubAdminController;
use App\Http\Controllers\Admin\LoginController;

use App\Http\Controllers\CMS\AboutPageController;
use App\Http\Controllers\CMS\ContactUsPageController;
use App\Http\Controllers\CMS\PrivacyPolicyPageController;

use App\Http\Controllers\BannerController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\TagsController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\SpecializationController;
use App\Http\Controllers\DoctorController;
use App\Http\Controllers\SettingController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

//Auth routes.
Route::get('/', [LoginController::class, 'showLoginForm'])->name('admin.login');
Route::get('/login', [LoginController::class, 'showLoginForm'])->name('admin.login');
Route::post('/login', [LoginController::class, 'login'])->name('admin.login');
 
   
$router->group(['middleware' => ['auth:admin']], function($router)
{
    Route::get('/home', [HomeController::class, 'index'])->name('admin.home');
    Route::post('/logout', [LoginController::class, 'logout'])->name('admin.logout');

    //Banner
    Route::get('/banners/data', [BannerController::class, 'data']);
    Route::post('/banners/status', [BannerController::class, 'status']);
    Route::resource('banners', BannerController::class)->missing(function (Request $request) {
            return Redirect::route('banners.index');
        });

    //Notification
    Route::get('/notifications/data', [NotificationController::class, 'data']);
    Route::post('/notifications/status', [NotificationController::class, 'status']);
    Route::resource('notifications', NotificationController::class)->missing(function (Request $request) {
            return Redirect::route('notifications.index');
        });

    //User
    Route::get('/users/data', [UserController::class, 'data']);
    Route::post('/users/status', [UserController::class, 'status']);
    Route::resource('users', UserController::class)->missing(function (Request $request) {
            return Redirect::route('users.index');
        });

    //Sub Admin
    Route::get('/sub-admin/data', [SubAdminController::class, 'data']);
    Route::post('/sub-admin/status', [SubAdminController::class, 'status']);
    Route::post('/sub-admin/update', [SubAdminController::class, 'update']);
    Route::resource('sub-admin', SubAdminController::class)->missing(function (Request $request) {
            return Redirect::route('sub-admin.index');
        });

    //Category
    Route::get('/categories/data', [CategoryController::class, 'data']);
    Route::post('/categories/status', [CategoryController::class, 'status']);
    Route::post('/categories/update', [CategoryController::class, 'update']);
    Route::resource('categories', CategoryController::class)->missing(function (Request $request) {
            return Redirect::route('categories.index');
        });

    //Tags
    Route::get('/tags/data', [TagsController::class, 'data']);
    Route::post('/tags/status', [TagsController::class, 'status']);
    Route::post('/tags/update', [TagsController::class, 'update']);
    Route::resource('tags', TagsController::class)->missing(function (Request $request) {
            return Redirect::route('tags.index');
        });

    //Post
    Route::get('/posts/data', [PostController::class, 'data']);
    Route::post('/posts/status', [PostController::class, 'status']);
    Route::post('/posts/update', [PostController::class, 'update']);
    Route::resource('posts', PostController::class)->missing(function (Request $request) {
            return Redirect::route('posts.index');
        });

    //Specialization
    Route::get('/specializations/data', [SpecializationController::class, 'data']);
    Route::post('/specializations/status', [SpecializationController::class, 'status']);
    Route::post('/specializations/update', [SpecializationController::class, 'update']);
    Route::resource('specializations', SpecializationController::class)->missing(function (Request $request) {
            return Redirect::route('specializations.index');
        });

    //Doctor
    Route::get('/doctors/data', [DoctorController::class, 'data']);
    Route::get('/doctors/featured', [DoctorController::class, 'featured']);
    Route::get('/doctors/featured/data', [DoctorController::class, 'featured_data']);
    Route::post('/doctors/status', [DoctorController::class, 'status']);
    Route::post('/doctors/update', [DoctorController::class, 'update']);
    Route::resource('doctors', DoctorController::class)->missing(function (Request $request) {
            return Redirect::route('doctors.index');
        });


    //CMS About
    Route::get('/cms/about/data', [AboutPageController::class, 'data']);
    Route::post('/cms/about/update', [AboutPageController::class, 'update']);
    Route::resource('cms/about', AboutPageController::class)->missing(function (Request $request) {
            return Redirect::route('cms/about.index');
        });

    //CMS Contact Us
    Route::get('/cms/contact-us/data', [ContactUsPageController::class, 'data']);
    Route::post('/cms/contact-us/update', [ContactUsPageController::class, 'update']);
    Route::resource('cms/contact-us', ContactUsPageController::class)->missing(function (Request $request) {
            return Redirect::route('cms/contact-us.index');
        });

    //CMS Privacy Policy
    Route::get('/cms/privacy-policy/data', [PrivacyPolicyPageController::class, 'data']);
    Route::post('/cms/privacy-policy/update', [PrivacyPolicyPageController::class, 'update']);
    Route::resource('cms/privacy-policy', PrivacyPolicyPageController::class)->missing(function (Request $request) {
            return Redirect::route('cms/privacy-policy.index');
        });


    //Settings
    Route::get('/settings/data', [SettingController::class, 'data']);
    Route::post('/settings/update', [SettingController::class, 'update']);
    Route::resource('settings', SettingController::class)->missing(function (Request $request) {
            return Redirect::route('settings.index');
        });

});

