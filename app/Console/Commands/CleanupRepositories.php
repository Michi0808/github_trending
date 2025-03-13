<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CleanupRepositories extends Command
{
    // Command name
    protected $signature = 'cleanup:repositories';

    // Command description
    protected $description = 'Delete old repositories from the database';

    public function handle()
    {
        // Delete repositories older than 24 hours
        $deletedRows = DB::table('repositories')
            ->where('created_at', '<', now()->subDay())
            ->delete();

        $this->info("Deleted $deletedRows old repositories.");
    }
}
