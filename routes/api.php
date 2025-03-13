<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;

// 🔹 API health check
Route::get('/', function () {
    return response()->json(['message' => 'API is running']);
});

// 🔹 Cron job to fetch GitHub Trending repositories every 10 minutes
Route::get('/run-cron', function () {
    Artisan::call('fetch:github-trending');
    return response()->json(['message' => 'GitHub Trending fetch job triggered']);
});

// 🔹 Cron job to clean up old repository data once per day
Route::get('/cleanup-cron', function () {
    Artisan::call('cleanup:repositories');
    return response()->json(['message' => 'Repository cleanup job triggered']);
});

// 🔹 API to fetch all repositories (for frontend use)
Route::get('/repositories', function () {
    return response()->json(DB::table('repositories')->orderBy('stars', 'desc')->get());
});

// 🔹 API to search repositories based on query parameters
Route::get('/search', function (Request $request) {
    $query = DB::table('repositories');

    // Filter by repository name
    if ($request->has('name')) {
        $query->where('repo_name', 'like', '%' . $request->input('name') . '%');
    }

    // Filter by programming language
    if ($request->has('language')) {
        $query->where('language', $request->input('language'));
    }

    // Filter by minimum stars
    if ($request->has('stars')) {
        $query->where('stars', '>=', $request->input('stars'));
    }

    return response()->json($query->orderBy('stars', 'desc')->get());
});
