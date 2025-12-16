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
use App\Http\Controllers\Admin\ChatbotFaqController;
use App\Http\Controllers\ArticleController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\AppSettingController;
use App\Http\Controllers\ActivityLogController;
use App\Services\FirebaseService;

Route::get('/', function () {
    return redirect('/admin/login');
});

// Test Firebase Connection - Auth Only (Firestore requires gRPC extension)
Route::get('/test-firebase', function () {
    try {
        $factory = (new \Kreait\Firebase\Factory)
            ->withServiceAccount(base_path(env('FIREBASE_CREDENTIALS')));
        
        $auth = $factory->createAuth();
        
        // Get list of users from Firebase Authentication
        $users = $auth->listUsers($maxResults = 5);
        
        $userList = [];
        foreach ($users as $user) {
            $userList[] = [
                'uid' => $user->uid,
                'email' => $user->email,
                'displayName' => $user->displayName,
                'emailVerified' => $user->emailVerified,
                'disabled' => $user->disabled,
            ];
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Firebase Authentication connected successfully',
            'note' => 'Showing users from Firebase Authentication (Firestore requires gRPC extension for full integration)',
            'users_count' => count($userList),
            'users' => $userList
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'error' => $e->getMessage()
        ], 500);
    }
});

// Admin Authentication Routes
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminController::class, 'showLoginForm'])->name('admin.login');
    Route::post('/login', [AdminController::class, 'login'])->name('admin.login.post');
    Route::post('/logout', [AdminController::class, 'logout'])->name('admin.logout');
    
    // Protected Admin Routes
    Route::middleware(['auth'])->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');
        
        // Profile Management
        Route::prefix('profile')->group(function () {
            Route::get('/', function () {
                return view('admin.profile.index');
            })->name('admin.profile.index');
            Route::put('/update', function () {
                return redirect()->route('admin.profile.index')->with('success', 'Profil berhasil diperbarui!');
            })->name('admin.profile.update');
            Route::put('/password', function () {
                return redirect()->route('admin.profile.index')->with('success', 'Kata sandi berhasil diubah!');
            })->name('admin.profile.password');
        });
        
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
            Route::get('/create', [TransactionController::class, 'create'])->name('admin.transactions.create');
            Route::post('/', [TransactionController::class, 'store'])->name('admin.transactions.store');
            Route::get('/{id}/edit', [TransactionController::class, 'edit'])->name('admin.transactions.edit');
            Route::put('/{id}', [TransactionController::class, 'update'])->name('admin.transactions.update');
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
        
        // Article Management
        Route::prefix('articles')->group(function () {
            Route::get('/', [ArticleController::class, 'index'])->name('articles.index');
            Route::get('/create', [ArticleController::class, 'create'])->name('articles.create');
            Route::post('/', [ArticleController::class, 'store'])->name('articles.store');
            Route::get('/{article}', [ArticleController::class, 'show'])->name('articles.show');
            Route::get('/{article}/edit', [ArticleController::class, 'edit'])->name('articles.edit');
            Route::put('/{article}', [ArticleController::class, 'update'])->name('articles.update');
            Route::delete('/{article}', [ArticleController::class, 'destroy'])->name('articles.destroy');
            Route::post('/{article}/toggle-publish', [ArticleController::class, 'togglePublish'])->name('articles.toggle-publish');
        });
        
        // Notification Management
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index'])->name('notifications.index');
            Route::get('/create', [NotificationController::class, 'create'])->name('notifications.create');
            Route::post('/', [NotificationController::class, 'store'])->name('notifications.store');
            Route::get('/{notification}', [NotificationController::class, 'show'])->name('notifications.show');
            Route::delete('/{notification}', [NotificationController::class, 'destroy'])->name('notifications.destroy');
            Route::post('/broadcast', [NotificationController::class, 'sendBroadcast'])->name('notifications.broadcast');
        });
        
        // Chatbot FAQ Management
        Route::prefix('chatbot-faqs')->group(function () {
            Route::get('/', [ChatbotFaqController::class, 'index'])->name('admin.chatbot-faqs.index');
            Route::get('/create', [ChatbotFaqController::class, 'create'])->name('admin.chatbot-faqs.create');
            Route::post('/', [ChatbotFaqController::class, 'store'])->name('admin.chatbot-faqs.store');
            Route::get('/{chatbotFaq}', [ChatbotFaqController::class, 'show'])->name('admin.chatbot-faqs.show');
            Route::get('/{chatbotFaq}/edit', [ChatbotFaqController::class, 'edit'])->name('admin.chatbot-faqs.edit');
            Route::put('/{chatbotFaq}', [ChatbotFaqController::class, 'update'])->name('admin.chatbot-faqs.update');
            Route::delete('/{chatbotFaq}', [ChatbotFaqController::class, 'destroy'])->name('admin.chatbot-faqs.destroy');
            Route::post('/{chatbotFaq}/toggle-status', [ChatbotFaqController::class, 'toggleStatus'])->name('admin.chatbot-faqs.toggle-status');
            Route::post('/{chatbotFaq}/reset-usage', [ChatbotFaqController::class, 'resetUsage'])->name('admin.chatbot-faqs.reset-usage');
        });
        
        // App Settings
        Route::prefix('settings')->group(function () {
            Route::get('/', [AppSettingController::class, 'index'])->name('settings.index');
            Route::get('/create', [AppSettingController::class, 'create'])->name('settings.create');
            Route::post('/', [AppSettingController::class, 'store'])->name('settings.store');
            Route::get('/{setting}/edit', [AppSettingController::class, 'edit'])->name('settings.edit');
            Route::put('/{setting}', [AppSettingController::class, 'update'])->name('settings.update');
            Route::delete('/{setting}', [AppSettingController::class, 'destroy'])->name('settings.destroy');
            Route::post('/bulk-update', [AppSettingController::class, 'bulkUpdate'])->name('settings.bulk-update');
        });
        
        // Activity Logs
        Route::prefix('activity-logs')->group(function () {
            Route::get('/', [ActivityLogController::class, 'index'])->name('activity-logs.index');
            Route::get('/{activityLog}', [ActivityLogController::class, 'show'])->name('activity-logs.show');
            Route::delete('/{activityLog}', [ActivityLogController::class, 'destroy'])->name('activity-logs.destroy');
            Route::post('/clear-old', [ActivityLogController::class, 'clearOld'])->name('activity-logs.clear-old');
        });
    });
});
