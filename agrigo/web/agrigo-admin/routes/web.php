<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\TransactionController;
use App\Http\Controllers\Admin\CommodityController;
use App\Http\Controllers\Admin\ScheduleController;
use App\Http\Controllers\Admin\WeatherController;
use App\Http\Controllers\Admin\ReportController;

Route::get('/', function () {
    return redirect('/admin/login');
});

// Admin Authentication Routes
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminController::class, 'showLoginForm'])->name('admin.login');
    Route::post('/login', [AdminController::class, 'login'])->name('admin.login.post');
    Route::post('/logout', [AdminController::class, 'logout'])->name('admin.logout');
    
    // Protected Admin Routes
    Route::middleware(['auth'])->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');
        
        // User Management
        Route::prefix('users')->group(function () {
            Route::get('/', [UserController::class, 'index'])->name('admin.users.index');
            Route::get('/{id}', [UserController::class, 'show'])->name('admin.users.show');
            Route::get('/{id}/edit', [UserController::class, 'edit'])->name('admin.users.edit');
            Route::put('/{id}', [UserController::class, 'update'])->name('admin.users.update');
            Route::delete('/{id}', [UserController::class, 'destroy'])->name('admin.users.destroy');
            Route::post('/{id}/toggle-status', [UserController::class, 'toggleStatus'])->name('admin.users.toggle-status');
        });
        
        // Transaction Management
        Route::prefix('transactions')->group(function () {
            Route::get('/', [TransactionController::class, 'index'])->name('admin.transactions.index');
            Route::get('/{id}', [TransactionController::class, 'show'])->name('admin.transactions.show');
            Route::put('/{id}/status', [TransactionController::class, 'updateStatus'])->name('admin.transactions.update-status');
            Route::delete('/{id}', [TransactionController::class, 'destroy'])->name('admin.transactions.destroy');
        });
        
        // Commodity Management
        Route::prefix('commodities')->group(function () {
            Route::get('/', [CommodityController::class, 'index'])->name('admin.commodities.index');
            Route::get('/create', [CommodityController::class, 'create'])->name('admin.commodities.create');
            Route::post('/', [CommodityController::class, 'store'])->name('admin.commodities.store');
            Route::get('/{id}', [CommodityController::class, 'show'])->name('admin.commodities.show');
            Route::get('/{id}/edit', [CommodityController::class, 'edit'])->name('admin.commodities.edit');
            Route::put('/{id}', [CommodityController::class, 'update'])->name('admin.commodities.update');
            Route::delete('/{id}', [CommodityController::class, 'destroy'])->name('admin.commodities.destroy');
            Route::post('/{id}/toggle-status', [CommodityController::class, 'toggleStatus'])->name('admin.commodities.toggle-status');
        });
        
        // Schedule Management
        Route::prefix('schedules')->group(function () {
            Route::get('/', [ScheduleController::class, 'index'])->name('admin.schedules.index');
            Route::get('/create', [ScheduleController::class, 'create'])->name('admin.schedules.create');
            Route::post('/', [ScheduleController::class, 'store'])->name('admin.schedules.store');
            Route::get('/{id}', [ScheduleController::class, 'show'])->name('admin.schedules.show');
            Route::get('/{id}/edit', [ScheduleController::class, 'edit'])->name('admin.schedules.edit');
            Route::put('/{id}', [ScheduleController::class, 'update'])->name('admin.schedules.update');
            Route::delete('/{id}', [ScheduleController::class, 'destroy'])->name('admin.schedules.destroy');
            Route::put('/{id}/status', [ScheduleController::class, 'updateStatus'])->name('admin.schedules.update-status');
        });
        
        // Weather Data Management
        Route::prefix('weather')->group(function () {
            Route::get('/', [WeatherController::class, 'index'])->name('admin.weather.index');
            Route::get('/create', [WeatherController::class, 'create'])->name('admin.weather.create');
            Route::post('/', [WeatherController::class, 'store'])->name('admin.weather.store');
            Route::delete('/{id}', [WeatherController::class, 'destroy'])->name('admin.weather.destroy');
        });
        
        // Reports & Analytics
        Route::get('/reports', [ReportController::class, 'index'])->name('admin.reports.index');
    });
});
