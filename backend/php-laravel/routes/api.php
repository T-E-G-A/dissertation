<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\FeeController;
use App\Http\Controllers\LearnerController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ResultController;
use App\Http\Controllers\TimetableController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public Routes
Route::get('/', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Welcome to the School-MIS API-Laravel endpoint'
    ]);
});

// Authentication Routes
Route::prefix('admin')->group(function () {
    Route::post('/login', [AdminController::class, 'login']);
});

Route::prefix('learner')->group(function () {
    Route::post('/login', [LearnerController::class, 'login']);
    Route::post('/register', [LearnerController::class, 'register']);
    Route::get('/timetables/download/{id}', [TimetableController::class, 'download'])
        ->name('timetable.download');
});

// Protected Admin Routes
Route::middleware(['auth:sanctum', 'is_admin'])
    ->prefix('admin')
    ->group(function () {
        // Dashboard
        Route::get('/dashboard-summary', [DashboardController::class, 'getSummary']);
        
        // User Management
        Route::post('/approve-learner', [AdminController::class, 'approveLearner']);
        Route::post('/logout', [AdminController::class, 'logout']);
        Route::get('/students', [LearnerController::class, 'index']);
        
        // Attendance Management
        Route::prefix('attendance')->group(function () {
            Route::get('/', [AttendanceController::class, 'getAttendance']);
            Route::post('/', [AttendanceController::class, 'updateAttendance']);
        });
        
        // Fees Management
        Route::prefix('fees')->group(function () {
            Route::get('/', [FeeController::class, 'index']);
            Route::post('/reset', [FeeController::class, 'reset']);
            Route::post('/save', [FeeController::class, 'save']);
        });
        
        // Results Management
        Route::prefix('results')->group(function () {
            Route::get('/', [ResultController::class, 'index']);
            Route::post('/reset', [ResultController::class, 'reset']);
            Route::post('/save', [ResultController::class, 'save']);
        });
        
        // Timetables Management
        Route::prefix('timetables')->group(function () {
            Route::get('/', [TimetableController::class, 'index']);
            Route::post('/upload', [TimetableController::class, 'upload']);
            Route::delete('/{id}', [TimetableController::class, 'delete']);
        });
        
        // Notifications Management
        Route::prefix('notifications')->group(function () {
            Route::post('/send', [NotificationController::class, 'send']);
            Route::post('/send-bulk', [NotificationController::class, 'sendBulk']);
        });
    });

// Protected Learner Routes
Route::middleware('auth:sanctum')
    ->prefix('learner')
    ->group(function () {
        // Profile
        Route::get('/profile', [LearnerController::class, 'profile']);
        Route::post('/logout', [LearnerController::class, 'logout']);
        
        // Learner Resources
        Route::get('/fees', [FeeController::class, 'learnerFees']);
        Route::post('/pay-fees', [FeeController::class, 'payFees']);
        Route::post('/notifications', [NotificationController::class, 'learnerNotifications']);
        Route::post('/results', [ResultController::class, 'learnerResults']);
        Route::get('/timetables', [TimetableController::class, 'learnerTimetables']);
    });