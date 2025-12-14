<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FarmerController;
use App\Http\Controllers\Api\NotificationController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Schedules
    Route::get('/schedules', [FarmerController::class, 'schedules']);
    Route::post('/schedules', [FarmerController::class, 'createSchedule']);
    Route::put('/schedules/{id}', [FarmerController::class, 'updateSchedule']);
    Route::delete('/schedules/{id}', [FarmerController::class, 'deleteSchedule']);
    
    // Transactions
    Route::get('/transactions', [FarmerController::class, 'transactions']);
    Route::post('/transactions', [FarmerController::class, 'createTransaction']);
    Route::get('/transactions/summary', [FarmerController::class, 'transactionSummary']);
    
    // Commodities
    Route::get('/commodities', [FarmerController::class, 'commodities']);
    
    // Weather
    Route::get('/weather', [FarmerController::class, 'weather']);
    
    // FCM Token
    Route::post('/fcm-token', [NotificationController::class, 'saveFcmToken']);
});
