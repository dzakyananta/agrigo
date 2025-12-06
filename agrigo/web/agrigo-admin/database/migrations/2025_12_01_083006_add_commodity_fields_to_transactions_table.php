<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->foreignId('commodity_id')->nullable()->after('user_id')->constrained('commodities');
            $table->decimal('quantity', 10, 2)->nullable()->after('amount');
            $table->decimal('price_per_unit', 15, 2)->nullable()->after('quantity');
            $table->enum('status', ['pending', 'confirmed', 'completed', 'cancelled'])->default('pending')->after('description');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropForeign(['commodity_id']);
            $table->dropColumn(['commodity_id', 'quantity', 'price_per_unit', 'status']);
        });
    }
};
