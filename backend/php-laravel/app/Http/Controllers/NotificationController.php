<?php

// app/Http/Controllers/NotificationController.php
namespace App\Http\Controllers;

use App\Models\Learner;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class NotificationController extends Controller
{
    public function getStudents()
    {
        try {
            $students = Learner::select('admissionNumber', 'firstName', 'lastName', 'paidFees')
                ->get()
                ->map(function ($student) {
                    return [
                        'admission' => $student->admissionNumber,
                        'name' => $student->firstName . ' ' . $student->lastName,
                        'paidFees' => $student->paidFees
                    ];
                });

            error_log('Successfully fetched students data: ' . count($students) . ' records');
            return response()->json([
                'status' => 'success',
                'data' => $students
            ]);
        } catch (\Exception $e) {
            error_log('Error fetching students: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch students data'
            ], 500);
        }
    }

    public function send(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'admission_number' => 'required|string|exists:learners,admissionNumber',
                'message' => 'required|string|max:500',
            ]);

            if ($validator->fails()) {
                error_log('Validation failed for sending notification: ' . json_encode($validator->errors()));
                return response()->json([
                    'status' => 'error',
                    'message' => 'Invalid data provided',
                    'errors' => $validator->errors()
                ], 422);
            }

            $notification = Notification::create([
                'admissionNumber' => $request->admission_number,
                'message' => $request->message,
                'category' => 'individual',
                'sent_by' => $request->user()->staffNumber // Assuming staff authentication
            ]);

            error_log("Notification sent to student {$request->admission_number}");

            return response()->json([
                'status' => 'success',
                'message' => 'Notification sent successfully',
                'data' => $notification
            ]);
        } catch (\Exception $e) {
            error_log('Error sending notification: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to send notification'
            ], 500);
        }
    }

    public function sendBulk(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'category' => 'required|string|in:all,fee_defaulters',
                'message' => 'required|string|max:500',
                'fee_threshold' => 'required_if:category,fee_defaulters|nullable|integer|min:0'
            ]);

            if ($validator->fails()) {
                error_log('Validation failed for bulk notification: ' . json_encode($validator->errors()));
                return response()->json([
                    'status' => 'error',
                    'message' => 'Invalid data provided',
                    'errors' => $validator->errors()
                ], 422);
            }

            $query = Learner::query();

            if ($request->category === 'fee_defaulters') {
                error_log('Sending bulk notifications to fee defaulters');
                if (!$request->fee_threshold) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Fee threshold is required for fee defaulters'
                    ], 422);
                }
                $query->join('fees', 'learners.admissionNumber', '=', 'fees.admissionNumber') 
                  ->where('fees.paid_amount', '<', $request->fee_threshold);
            } else {
                error_log('Sending bulk notifications to all learners');
            }

            $learners = $query->get();
            $sent_count = 0;

            foreach ($learners as $learner) {
                Notification::create([
                    'admissionNumber' => $learner->admissionNumber,
                    'message' => $request->message,
                    'category' => $request->category,
                    // 'sent_by' => $request->user()->staffNumber
                ]);
                $sent_count++;
            }

            error_log("Bulk notifications sent to {$sent_count} learners");

            return response()->json([
                'status' => 'success',
                'message' => 'Bulk notifications sent successfully',
                'data' => [
                    'recipients_count' => $sent_count
                ]
            ]);
        } catch (\Exception $e) {
            error_log('Error sending bulk notifications: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to send bulk notifications'
            ], 500);
        }
    }
    // Implement Learner notification
    // Route::get('/learner/notifications', [NotificationController::class, 'learnerNotifications']);
    public function learnerNotifications(Request $request)
    {
        $learner = $request->user();
        $notifications = Notification::where('admissionNumber', $learner->admissionNumber)
            ->get()
            ->map(function ($notification) {
                return [
                    'message' => $notification->message,
                    'category' => $notification->category,
                    'created_at' => $notification->created_at
                ];
            });
        error_log('Fetched notifications data: for '.$learner->admissionNumber.' - ' . count($notifications) . ' records');
        error_log($notifications);

        return response()->json([
            'status' => 'success',
            'data' => $notifications
        ]);
    }

}
