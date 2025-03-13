protected function schedule(Schedule $schedule)
{
    // Run every 10 minutes to fetch trending repositories
    $schedule->command('fetch:github-trending')->everyTenMinutes();

    // Run daily to delete old data
    $schedule->command('cleanup:repositories')->daily();
}
