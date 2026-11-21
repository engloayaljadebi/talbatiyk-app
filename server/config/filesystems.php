<?php

$supabaseStorage = env('SUPABASE_STORAGE', false);
$supabaseS3 = [
    'driver' => 'supabase-s3',
    'key' => env('SUPABASE_S3_KEY'),
    'secret' => env('SUPABASE_S3_SECRET'),
    'region' => env('SUPABASE_S3_REGION'),
    'endpoint' => env('SUPABASE_S3_ENDPOINT'),
    'use_path_style_endpoint' => true,
    'retain_visibility' => false,
    'request_checksum_calculation' => 'when_required',
    'response_checksum_validation' => 'when_required',
];

return [

    /*
    |--------------------------------------------------------------------------
    | Default Filesystem Disk
    |--------------------------------------------------------------------------
    |
    | Here you may specify the default filesystem disk that should be used
    | by the framework. The "local" disk, as well as a variety of cloud
    | based disks are available to your application for file storage.
    |
    */

    'default' => env('FILESYSTEM_DISK', 'local'),

    /*
    |--------------------------------------------------------------------------
    | Filesystem Disks
    |--------------------------------------------------------------------------
    |
    | Below you may configure as many filesystem disks as necessary, and you
    | may even configure multiple disks for the same driver. Examples for
    | most supported storage drivers are configured here for reference.
    |
    | Supported drivers: "local", "ftp", "sftp", "s3"
    |
    */

    'disks' => [

        'local' => [
            'driver' => 'local',
            'root' => storage_path('app/private'),
            'serve' => true,
            'throw' => false,
            'report' => false,
        ],

        'talbytk_private' => $supabaseStorage ? array_merge($supabaseS3, [
            'bucket' => env('SUPABASE_PRIVATE_BUCKET'),
            'visibility' => 'private',
            'throw' => true,
        ]) : [
            'driver' => 'local',
            'root' => storage_path('app/private/talbytk'),
            'visibility' => 'private',
            'throw' => true,
        ],

        'public' => $supabaseStorage ? array_merge($supabaseS3, [
            'bucket' => env('SUPABASE_PUBLIC_BUCKET'),
            'url' => rtrim((string) env('SUPABASE_URL'), '/').'/storage/v1/object/public/'.env('SUPABASE_PUBLIC_BUCKET'),
            'visibility' => 'public',
            'throw' => false,
            'report' => true,
        ]) : [
            'driver' => 'local',
            'root' => storage_path('app/public'),
            'url' => rtrim(env('APP_URL', 'http://localhost'), '/').'/storage',
            'visibility' => 'public',
            'throw' => false,
            'report' => false,
        ],

        's3' => [
            'driver' => 's3',
            'key' => env('AWS_ACCESS_KEY_ID'),
            'secret' => env('AWS_SECRET_ACCESS_KEY'),
            'region' => env('AWS_DEFAULT_REGION'),
            'bucket' => env('AWS_BUCKET'),
            'url' => env('AWS_URL'),
            'endpoint' => env('AWS_ENDPOINT'),
            'use_path_style_endpoint' => env('AWS_USE_PATH_STYLE_ENDPOINT', false),
            'throw' => false,
            'report' => false,
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Symbolic Links
    |--------------------------------------------------------------------------
    |
    | Here you may configure the symbolic links that will be created when the
    | `storage:link` Artisan command is executed. The array keys should be
    | the locations of the links and the values should be their targets.
    |
    */

    'links' => [
        public_path('storage') => storage_path('app/public'),
    ],

];
