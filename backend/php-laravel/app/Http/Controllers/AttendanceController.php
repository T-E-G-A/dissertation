<?php

namespace App\Http\Controllers;

use App\Models\Learner;
use App\Models\AttendanceRecord;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AttendanceController extends Controller
{
    public function getAttendance(Request $request)
    {
        try {
            $week = $request->query('week');
            if (!$week) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Week parameter is required.',
                ], 400);
            }

            // Get all learners
            $learners = Learner::select(
                'learners.admissionNumber',
                DB::raw("CONCAT(learners.firstName, ' ', learners.lastName) as name")
            )->get();

            // Get attendance records for the specified week
            $weekNumber = (int) substr($week, 5); // Extract week number from "Week X"
            $attendanceRecords = AttendanceRecord::where('week_number', $weekNumber)
                ->get()
                ->groupBy('admissionNumber');

            // Prepare the response data
            $data = $learners->map(function ($learner, $index) use ($attendanceRecords) {
                $attendance = array_fill(0, 5, false); // Initialize with false for all 5 days

                if (isset($attendanceRecords[$learner->admissionNumber])) {
                    foreach ($attendanceRecords[$learner->admissionNumber] as $record) {
                        $attendance[$record->day_of_week - 1] = $record->present == 1; // Use $record->present directly
                    }
                }

                return [
                    'no' => $index + 1,
                    'name' => $learner->name,
                    'admissionNumber' => $learner->admissionNumber,
                    'attendance' => $attendance,
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $data
            ]);
        } catch (\Exception $e) {
            error_log("Error in getAttendance: " . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while fetching attendance.',
            ], 500);
        }
    }

    public function updateAttendance(Request $request)
    {
        try {
            $request->validate([
                'week' => 'required|string',
                'attendance' => 'required|array',
            ]);

            DB::beginTransaction();

            foreach ($request->attendance as $record) {
                foreach ($record['attendance'] as $dayIndex => $present) {
                    AttendanceRecord::updateOrCreate(
                        [
                            'admissionNumber' => $record['admissionNumber'],
                            'week_number' => (int) substr($request->week, 5),
                            'day_of_week' => $dayIndex + 1,
                        ],
                        [
                            'present' => $present,
                        ]
                    );
                }
            }

            DB::commit();
            return response()->json([
                'status' => 'success',
                'message' => 'Attendance updated successfully',
            ]);
        } catch (ValidationException $e) {
            DB::rollBack();
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            DB::rollBack();
            error_log("Error in updateAttendance: " . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while updating attendance.',
            ], 500);
        }
    }
}
