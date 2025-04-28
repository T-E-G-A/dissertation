<?php

return [

    'defaults' => [
        'guard' => 'web',
        'passwords' => 'admins',
    ],

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'web',
        ],
        'admin' => [
            'driver' => 'sanctum',
            'provider' => 'admins',
        ],
        'learner' => [
            'driver' => 'sanctum',
            'provider' => 'learners',
        ],
    ],

    'providers' => [
        'admins' => [
            'driver' => 'eloquent',
            'model' => App\Models\Admin::class,
        ],
        'learners' => [
            'driver' => 'eloquent',
            'model' => App\Models\Learner::class,
        ],
        'web' => [
            'driver' => 'eloquent',
            'model' => App\Models\User::class,
        ],
    ],

    'passwords' => [
        'admins' => [
            'provider' => 'admins',
            'table' => 'admin_password_resets',
            'expire' => 60,
            'throttle' => 60,
        ],
        'learners' => [
            'provider' => 'learners',
            'table' => 'learner_password_resets',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    'password_timeout' => 10800,

];
