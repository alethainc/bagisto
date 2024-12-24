<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

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

// Add this route temporarily
Route::get('/db-test', function() {
    try {
        $connection = DB::connection()->getPdo();
        return [
            'status' => 'connected',
            'database' => DB::connection()->getDatabaseName(),
            'connection' => $connection->getAttribute(PDO::ATTR_CONNECTION_STATUS)
        ];
    } catch (\Exception $e) {
        return [
            'status' => 'error',
            'message' => $e->getMessage()
        ];
    }
});
