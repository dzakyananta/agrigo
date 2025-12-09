<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthApiController;
use App\Http\Controllers\Api\ScheduleApiController;
use App\Http\Controllers\Api\CommodityApiController;
use App\Http\Controllers\Api\TransactionApiController;
use App\Http\Controllers\Api\ChatbotApiController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::post('/register', [AuthApiController::class, 'register']);
Route::post('/login', [AuthApiController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::get('/profile', [AuthApiController::class, 'profile']);
    Route::put('/profile', [AuthApiController::class, 'updateProfile']);
    Route::post('/logout', [AuthApiController::class, 'logout']);
    
    // Commodities
    Route::get('/commodities', [CommodityApiController::class, 'index']);
    Route::get('/commodities/{id}', [CommodityApiController::class, 'show']);
    Route::get('/commodities/type/{type}', [CommodityApiController::class, 'getByType']);
    Route::get('/commodity-types', [CommodityApiController::class, 'getTypes']);
    
    // Schedules
    Route::get('/schedules', [ScheduleApiController::class, 'index']);
    Route::post('/schedules', [ScheduleApiController::class, 'store']);
    Route::put('/schedules/{id}', [ScheduleApiController::class, 'update']);
    Route::delete('/schedules/{id}', [ScheduleApiController::class, 'destroy']);
    
    // Transactions
    Route::get('/transactions', [TransactionApiController::class, 'index']);
    Route::get('/transactions/summary', [TransactionApiController::class, 'summary']);
    Route::post('/transactions', [TransactionApiController::class, 'store']);
    Route::get('/transactions/{id}', [TransactionApiController::class, 'show']);
    Route::put('/transactions/{id}', [TransactionApiController::class, 'update']);
    Route::delete('/transactions/{id}', [TransactionApiController::class, 'destroy']);
    
    // Chatbot FAQs
    Route::get('/chatbot/faqs', [ChatbotApiController::class, 'index']);
    Route::get('/chatbot/faqs/categories', [ChatbotApiController::class, 'getCategories']);
    Route::get('/chatbot/faqs/category/{category}', [ChatbotApiController::class, 'getByCategory']);
    Route::get('/chatbot/faqs/search', [ChatbotApiController::class, 'search']);
    Route::get('/chatbot/faqs/smart-search', [ChatbotApiController::class, 'smartSearch']);
    Route::get('/chatbot/faqs/{id}', [ChatbotApiController::class, 'show']);
});
