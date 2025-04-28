<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use Illuminate\Http\Request;
use App\Models\Learner;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Exception;
use App\Models\ActivityLog;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class AdminController extends Controller
{
    // Admin Login
    public function login(Request $request)
    {
        $credentials = $request->only('username', 'password');

        // Check if the admin exists
        $admin = Admin::where('username', $credentials['username'])->first();

        // If the admin does not exist
        if (!$admin) {
            error_log('Admin login attempt failed: User not found - ' . $credentials['username']);
            return response()->json([
                'status' => 'error',
                'message' => 'Administrator account not found.'
            ], 404);
        }

        // Check if the admin account is active
        if (!$admin->is_active) {
            error_log('Admin login attempt failed: Inactive account - ' . $credentials['username']);
            return response()->json([
                'status' => 'error',
                'message' => 'Administrator account is currently inactive'
            ], 403);
        }

        if ($admin->locked_until && $admin->locked_until < now()) { // reset
            $admin->login_attempts = 0;
            $admin->locked_until = null;
            $admin->save();
        }

        // Check if the admin account is locked due to too many failed attempts
        if ($admin->login_attempts >= env('ADMIN_MAX_LOGIN_ATTEMPTS', 3)) {
            $minutes_remaining = now()->diffInMinutes($admin->locked_until);
            error_log('Admin login attempt failed: Account locked - ' . $credentials['username']);
            return response()->json([
                'status' => 'error',
                'message' => "Account temporarily locked due to multiple failed attempts. Please try again in {$minutes_remaining} minutes."
            ], 423);
        }

        // Verify password
        if (password_verify($credentials['password'], $admin->password)) {
            // Reset login attempts on successful login
            $admin->login_attempts = 0;
            $admin->locked_until = null;
            $admin->last_login_at = now();
            $admin->save();

            error_log('Admin login successful: ' . $credentials['username']);

            return response()->json([
                'status' => 'success',
                'message' => 'Login successful',
                'token' => $admin->createToken('admin-token')->plainTextToken,
                'email' => $admin->email,
                'staffNumber' => $admin->staffNumber,
                'username' => $admin->username,
            ]);
        } else {
            // Increment login attempts
            $admin->login_attempts = ($admin->login_attempts ?? 0) + 1;

            // Lock account if too many failed attempts
            if ($admin->login_attempts >= env('ADMIN_MAX_LOGIN_ATTEMPTS', 3)) {
                $admin->locked_until = now()->addMinutes(env('ADMIN_LOCKOUT_DURATION', 5));
                error_log('Admin account locked due to multiple failed attempts: ' . $credentials['username']);
            }

            $admin->save();

            error_log('Admin login failed: Invalid password for ' . $credentials['username'] . ' - Attempts: ' . (4 - $admin->login_attempts));
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid password. Attempts: ' . (4 - $admin->login_attempts)
            ], 401);
        }
    }

    public function logout(Request $request)
    {
        // Revoke the token that was used to authenticate the current request
        $request->user()->currentAccessToken()->delete();

        return response()->json(['status' => 'success', 'message' => 'Logged out successfully']);
    }


    // Approve Learner Admission
    public function approveLearner(Request $request)
    {
        try {
            $request->validate([
                'staffNumber' => 'required|string|exists:admins,staffNumber',
                'students' => 'required|array',
                'students.*.admissionNumber' => 'required|string|exists:learners,admissionNumber',
                'students.*.admitted' => 'required|boolean',
            ]);

            DB::beginTransaction();

            $admin = Admin::where('staffNumber', $request->staffNumber)->first();
            if (!$admin) {
                error_log("Invalid staff number: {$request->staffNumber}"); 
                throw new Exception('Invalid staff number');
            }

            $updatedCount = 0;
            $errors = [];

            foreach ($request->students as $student) {
                try {
                    $learner = Learner::where('admissionNumber', $student['admissionNumber'])->first();
                    if ($learner) {
                        $oldStatus = $learner->admitted;
                        $learner->admitted = $student['admitted'];
                        $learner->updated_by = $admin->id;
                        $learner->save();

                        // Log the change
                        ActivityLog::create([
                            'admin_id' => $admin->id,
                            'action' => 'admission_status_change',
                            'description' => sprintf(
                                'Changed admission status for %s from %s to %s',
                                $learner->admissionNumber,
                                $oldStatus ? 'approved' : 'unapproved',
                                $student['admitted'] ? 'approved' : 'unapproved'
                            ),
                            'old_value' => $oldStatus,
                            'new_value' => $student['admitted'],
                        ]);

                        $updatedCount++;
                    }
                } catch (Exception $e) {
                    $errors[] = "Error updating {$student['admissionNumber']}: {$e->getMessage()}";
                    error_log("Error updating learner admission status: {$student['admissionNumber']} - {$e->getMessage()}"); 
                }
            }

            if ($updatedCount === 0 && !empty($errors)) {
                DB::rollBack();
                error_log("Failed to update any students: " . implode(', ', $errors)); 
                throw new Exception('Failed to update any students: ' . implode(', ', $errors));
            }

            DB::commit();

            return response()->json([
                'status' => 'success',
                'message' => "Successfully updated $updatedCount student(s)" .
                    (!empty($errors) ? " with " . count($errors) . " errors" : ""),
                'errors' => $errors
            ]);
        } catch (ValidationException $e) {
            error_log("Validation error in approveLearner: " . json_encode($e->errors())); 
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (Exception $e) {
            DB::rollBack();
            error_log("Error in approveLearner: {$e->getMessage()} - Staff Number: {$request->staffNumber}"); 
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while updating learners: ' . $e->getMessage()
            ], 500);
        }
    }
}
