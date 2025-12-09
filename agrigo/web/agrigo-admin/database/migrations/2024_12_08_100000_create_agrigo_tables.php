<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Drop tables jika sudah ada untuk fresh migration
        Schema::dropIfExists('activity_logs');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('chatbot_faqs');
        Schema::dropIfExists('app_settings');
        Schema::dropIfExists('articles');
        Schema::dropIfExists('weather_data');
        Schema::dropIfExists('schedules');
        Schema::dropIfExists('transactions');
        Schema::dropIfExists('commodities');
        Schema::dropIfExists('user_profiles');
        Schema::dropIfExists('users');

        // 1. Users Table
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->enum('role', ['admin', 'farmer'])->default('farmer');
            $table->boolean('is_active')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });

        // 2. User Profiles Table
        Schema::create('user_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('phone')->nullable();
            $table->text('address')->nullable();
            $table->string('location')->nullable(); // Kota untuk cuaca
            $table->timestamps();
        });

        // 3. Commodities Table - Simple
        Schema::create('commodities', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Padi, Jagung, Cabai, dll
            $table->string('type'); // Padi-padian, Palawija, Sayuran, Umbi-umbian
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // 4. Transactions Table - Income/Expense
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('commodity_id')->nullable()->constrained()->onDelete('set null');
            $table->enum('type', ['income', 'expense']);
            $table->string('source')->nullable(); // Sumber pemasukan/pengeluaran
            $table->decimal('amount', 15, 2);
            $table->text('description')->nullable();
            $table->date('date');
            $table->timestamps();
            
            $table->index(['user_id', 'type']);
            $table->index('date');
        });

        // 5. Schedules Table - Jadwal Tanam
        Schema::create('schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('commodity_id')->constrained()->onDelete('cascade');
            $table->date('start_date');
            $table->date('end_date');
            $table->enum('status', ['active', 'completed', 'cancelled'])->default('active');
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        // 6. Articles Table - Artikel Dashboard
        Schema::create('articles', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('category'); // Tips Pertanian, Berita, Tutorial
            $table->text('content');
            $table->string('image_url')->nullable();
            $table->string('author')->default('Admin Agrigo');
            $table->boolean('is_published')->default(true);
            $table->integer('view_count')->default(0);
            $table->json('tags')->nullable();
            $table->timestamps();
        });

        // 7. Notifications Table
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description');
            $table->string('icon_type')->default('info');
            $table->string('color_type')->default('green');
            $table->foreignId('schedule_id')->nullable()->constrained()->onDelete('cascade');
            $table->boolean('is_read')->default(false);
            $table->timestamp('scheduled_at')->nullable();
            $table->boolean('is_sent')->default(false);
            $table->timestamps();
        });

        // 8. Chatbot FAQs Table
        Schema::create('chatbot_faqs', function (Blueprint $table) {
            $table->id();
            $table->string('category');
            $table->json('keywords');
            $table->text('question');
            $table->text('answer');
            $table->boolean('is_active')->default(true);
            $table->integer('usage_count')->default(0);
            $table->timestamps();
        });

        // 9. App Settings Table
        Schema::create('app_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->text('value');
            $table->string('type')->default('string');
            $table->string('category')->default('general');
            $table->text('description')->nullable();
            $table->timestamps();
        });

        // 10. Activity Logs Table
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade');
            $table->string('action');
            $table->string('module');
            $table->text('description');
            $table->string('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->json('data')->nullable();
            $table->timestamps();
        });

        // 11. Weather Data Table (Optional - untuk cache)
        Schema::create('weather_data', function (Blueprint $table) {
            $table->id();
            $table->string('location');
            $table->date('date');
            $table->decimal('temperature', 5, 2);
            $table->integer('humidity');
            $table->decimal('rainfall', 8, 2)->default(0);
            $table->decimal('wind_speed', 5, 2)->default(0);
            $table->string('condition')->nullable();
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('weather_data');
        Schema::dropIfExists('activity_logs');
        Schema::dropIfExists('app_settings');
        Schema::dropIfExists('chatbot_faqs');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('articles');
        Schema::dropIfExists('schedules');
        Schema::dropIfExists('transactions');
        Schema::dropIfExists('commodities');
        Schema::dropIfExists('user_profiles');
        Schema::dropIfExists('users');
    }
};
