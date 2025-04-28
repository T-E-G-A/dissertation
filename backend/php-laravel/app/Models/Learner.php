<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Learner extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;
    // Fields that can be mass-assigned
    protected $fillable = [
        'admissionNumber',
        'firstName', 
        'lastName', 
        'age', 
        'gender', 
        'parentName', 
        'parentEmail', 
        'parentPhone', 
        'password', 
        'admitted',
    ];

    // Automatically generate admissionNumber when a new learner is created
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($learner) {
            // Generate a sequential number padded to 4 digits
            $latestLearner = static::latest('id')->first();
            $nextNumber = $latestLearner ? $latestLearner->id + 1 : 1;
            $paddedNumber = str_pad($nextNumber, 4, '0', STR_PAD_LEFT);

            // Set the admission number
            $learner->admissionNumber = 'LNR/' . $paddedNumber . '/' . date('Y');
        });
    }
}
