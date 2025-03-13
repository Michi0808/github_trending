<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GitHubTrendingController;

// ✅ Catch-all route for Vue front-end (ensures Laravel serves the Vue app)
Route::get('/{any}', function () {
    return view('app'); // This should point to the Vue app
})->where('any', '.*');
