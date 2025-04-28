<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AttendanceRecord extends Model
{
    use HasFactory;
    protected $table = 'attendance_records';

    protected $fillable = [
        'admissionNumber',
        'week_number',
        'day_of_week',
        'present',
    ];

    public function learner()
    {
        return $this->belongsTo(Learner::class, 'admissionNumber', 'admissionNumber');
    }
}
