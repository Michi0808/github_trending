<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GitHub Trending</title>
    @php
        $viteUrl = config('app.url') . mix('/js/app.js');
    @endphp
    <script type="module" src="{{ $viteUrl }}"></script>
</head>
<body>
    <div id="app"></div>
</body>
</html>
