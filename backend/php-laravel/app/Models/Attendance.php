<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;
    
    protected $fillable = [
        'admissionNumber',
        'week',
        'attendance',
    ];

    protected $casts = [
        'attendance' => 'array',
    ];
}
