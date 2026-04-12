<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\AccountDeletionController;
use App\Http\Controllers\GetData;
use App\Http\Controllers\PrivacyPolicyController;

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

Route::get('/', function () {
    return view('sub-admin.login');
})->name('/')->middleware('guest:sub-admin');

Route::get('/clear-cache', function() {
    Artisan::call('config:clear');
    Artisan::call('cache:clear');
    Artisan::call('config:cache');
    return 'DONE'; //Return anything
});

// Auth::routes();

//Get Data
Route::get('/get-specializations/{id?}', [GetData::class, 'specializations']);
Route::get('/get-cms/{name?}', [GetData::class, 'cms']);
Route::get('/account-deletion', [AccountDeletionController::class, 'show'])->name('account-deletion.show');
Route::post('/account-deletion', [AccountDeletionController::class, 'store'])->name('account-deletion.store');
Route::get('/privacy-policy', [PrivacyPolicyController::class, 'show'])->name('privacy-policy.show');
