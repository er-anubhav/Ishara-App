<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\GetData;

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
// Auth::routes();
// Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');

Route::get('/', function () {
    return view('sub-admin.login');
})->name('/');

Route::get('/clear-cache', function() {
    Artisan::call('config:clear');
    Artisan::call('cache:clear');
    Artisan::call('config:cache');
    return 'DONE'; //Return anything
});


//Get Data
Route::get('/get-specializations/{id?}', [GetData::class, 'specializations']);
Route::get('/get-cms/{name?}', [GetData::class, 'cms']);
