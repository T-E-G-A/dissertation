<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Learner;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class LearnerController extends Controller
{
    public function index()
    {
        try {
            $learners = Learner::select(
                'learners.id as no',
                'learners.admissionNumber',
                'learners.firstName',
                'learners.lastName',
                DB::raw("CONCAT(learners.firstName, ' ', learners.lastName) as name"),
                'learners.age',
                'learners.gender',
                'learners.parentName',
                'learners.parentEmail',
                'learners.parentPhone',
                'learners.admitted',
                'fees.paid_amount',
                'fees.pending_amount'
            )
                ->leftJoin('fees', 'learners.admissionNumber', '=', 'fees.admissionNumber')
                ->get();

            // Calculate fee_balance for each learner
            $learners->transform(function ($learner) {
                $defaultFees = env('DEFAULT_FEES', 1500);
                $feeBalance = $defaultFees - ($learner->paid_amount ?? 0); 
                $learner->fee_balance = number_format($feeBalance, 2, '.', '');                 // remove paid_amount and pending_amount from the response
                unset($learner->paid_amount);
                unset($learner->pending_amount);
                return $learner;
            });

            return response()->json(['status' => 'success', 'data' => $learners]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    // Learner Login
    public function login(Request $request)
    {
        $credentials = $request->only('username', 'password');

        // Check if the learner exists
        $learner = Learner::where(function ($query) use ($credentials) {
            $query->where('admissionNumber', $credentials['username'])
                ->orWhere('parentEmail', $credentials['username']);
        })->first();

        // If the learner does not exist
        if (!$learner) {
            error_log('Learner login attempt failed: User not found - ' . $credentials['username']);
            return response()->json([
                'status' => 'error',
                'message' => 'Account not found'
            ], 404);
        }

        // If the learner exists but is not admitted
        if (!$learner->admitted) {
            error_log('Learner login attempt failed: Not admitted - ' . $credentials['username']);
            return response()->json([
                'status' => 'error',
                'message' => 'Learner is not admitted'
            ], 403);
        }

        // Check if account is active
        if (!$learner->is_active) {
            error_log('Learner login attempt failed: Inactive account - ' . $credentials['username']);
            return response()->json([
                'status' => 'error',
                'message' => 'Account is currently inactive. Please contact administration.'
            ], 403);
        }

        if ($learner->locked_until && $learner->locked_until > now()) { // reset
            $learner->login_attempts = 0;
            $learner->locked_until = null;
            $learner->save();
        }

        // Check if the account is locked due to too many failed attempts
        if ($learner->login_attempts >= env('LEARNER_MAX_LOGIN_ATTEMPTS', 3)) {
            $minutes_remaining = now()->diffInMinutes($learner->locked_until);
            error_log('Learner login attempt failed: Account locked - ' . $credentials['username']);
            return response()->json([
                'status' => 'error',
                'message' => "Account temporarily locked for security. Please try again in {$minutes_remaining} minutes."
            ], 423);
        }

        // Verify password
        if (password_verify($credentials['password'], $learner->password)) {
            // Reset security-related fields on successful login
            $learner->login_attempts = 0;
            $learner->locked_until = null;
            $learner->last_login_at = now();
            $learner->save();

            error_log('Learner login successful: ' . $credentials['username']);

            return response()->json([
                'status' => 'success',
                'message' => 'Login successful',
                'token' => $learner->createToken('learner-token')->plainTextToken,
                'admissionNumber' => $learner->admissionNumber,
                'username' => $learner->firstName . ' ' . $learner->lastName,
            ]);
        } else {
            // Increment login attempts
            $learner->login_attempts = ($learner->login_attempts ?? 0) + 1;

            // Lock account if too many failed attempts
            if ($learner->login_attempts >= env('LEARNER_MAX_LOGIN_ATTEMPTS', 3)) {
                $learner->locked_until = now()->addMinutes(env('LEARNER_LOCKOUT_DURATION', 10));
                error_log('Learner account locked due to multiple failed attempts: ' . $credentials['username']);
            }

            $learner->save();

            error_log('Learner login failed: Invalid password for ' . $credentials['username']);
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid password'
            ], 401);
        }
    }


    // Learner Registration
    public function register(Request $request)
    {
        $request->validate([
            'firstName' => 'required|string',
            'lastName' => 'required|string',
            'age' => 'required|integer',
            'gender' => 'required|string',
            'parentName' => 'required|string',
            'parentEmail' => 'required|email|unique:learners',
            'parentPhone' => 'required|string',
            'password' => 'required|string|min:6',
            // 'password' => 'required|string|min:8|confirmed|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$/',
        ]);

        try {
            $learner = Learner::create([
                'firstName' => $request->firstName,
                'lastName' => $request->lastName,
                'age' => $request->age,
                'gender' => $request->gender,
                'parentName' => $request->parentName,
                'parentEmail' => $request->parentEmail,
                'parentPhone' => $request->parentPhone,
                'password' => bcrypt($request->password),
                'admitted' => false, // Default to not admitted
            ]);

            Log::info('New learner registered: ' . $learner->firstName . '' . $learner->lastName);

            return response()->json([
                'status' => 'success',
                'message' => 'Your admission request is under approval. When approved, you will be able to log in using your email and password. Please be patient or come back later.',
            ]);
        } catch (\Exception $e) {
            Log::error('Learner registration failed: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while registering. Please try again later.',
            ], 500);
        }
    }
    public function profile(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'data' => $request->user()
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['status' => 'success', 'message' => 'Logged out']);
    }
}
