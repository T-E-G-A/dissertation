<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Learner;
use App\Models\Fee;
use App\Models\AttendanceRecord;
use App\Models\Result;

class DashboardController extends Controller
{
    public function getSummary(Request $request)
    {
        // Fetch learners data
        $learners = [
            'total' => Learner::count(),
            'male' => Learner::where('gender', 'male')->count(),
            'female' => Learner::where('gender', 'female')->count(),
        ];

        // Fetch fees data
        $fees = [
            'paid' => Fee::where('paid_amount', '>', 0)->count(),
            'pending' => Fee::where('pending_amount', '>', 0)->count(),
            'approvals' => Fee::where('approved', false)->count(),
        ];

        // Fetch attendance data from the new table
        $attendanceRecords = AttendanceRecord::all();

        $totalDays = $attendanceRecords->count(); // Total days recorded
        $totalAbsentees = $attendanceRecords->where('present', false)->count(); // Total absent days

        // Calculate average attendance
        $averageAttendance = ($totalDays > 0) ? (($totalDays - $totalAbsentees) / $totalDays) * 100 : 0;

        $attendance = [
            'absentees' => $totalAbsentees,
            'average' => round($averageAttendance, 2), // Average attendance percentage
        ];
        
        error_log(json_encode($attendance));
        // Fetch results data
        $results = [
            'upcoming' =>  Result::count(),
            'completed' => Result::count(),
        ];

        return response()->json([
            'status' => 'success',
            'data' => [
                'learners' => $learners,
                'fees' => $fees,
                'attendance' => $attendance,
                'results' => $results,
            ],
        ]);
    }
}
