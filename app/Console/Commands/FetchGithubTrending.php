<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use SimpleXMLElement;
use Illuminate\Support\Facades\Http;

class FetchGithubTrending extends Command
{
    // Command name
    protected $signature = 'fetch:github-trending';

    // Command description
    protected $description = 'Fetch GitHub Trending repositories and store them in Supabase';

    public function handle()
    {
        $api_url = "https://api.github.com/search/repositories?q=stars:>10000&sort=stars&order=desc";

        try {
            // Fetch RSS data using Laravel HTTP client (ignoring SSL errors)
            $response = Http::withHeaders([
                'Accept' => 'application/vnd.github.v3+json',
                'Authorization' => 'Bearer ' . env('GITHUB_ACCESS_TOKEN')
            ])->get($api_url);

            if (!$response->successful()) {
                throw new \Exception("Failed to fetch GitHub Trending data. HTTP Status: " . $response->status());
            }

            $repositories = $response->json()['items'];

            foreach ($repositories as $repo) {
                $title = $repo['name'];
                $owner = $repo['owner']['login'];
                $url = $repo['html_url'];
                $description = $repo['description'] ?? "";
                $language = $repo['language'] ?? "Unknown";
                $stars = $repo['stargazers_count'];

                // Insert only if the repository does not already exist in the database
                $exists = DB::table('repositories')->where('url', $url)->exists();
                if (!$exists) {
                    DB::table('repositories')->insert([
                        'repo_name' => $title,
                        'owner_name' => explode('/', $title)[0], // Extract repository owner
                        'stars' => $stars,
                        'language' => $language,
                        'description' => $description,
                        'url' => $url,
                        'created_at' => now(),
                    ]);
                    $this->info("Inserted: $title");
                } else {
                    $this->info("Already exists: $title");
                }
            }

            $this->info("✅ GitHub Trending data fetched and stored successfully!");
        } catch (\Exception $e) {
            $this->error("❌ Error: " . $e->getMessage());
        }
    }
}
