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
        Schema::table('bookings', function (Blueprint $table) {
      if (!Schema::hasColumn('bookings', 'paid_price')) {
            $table->decimal('paid_price', 8, 2)->nullable()->after('total_price');
        }
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropForeign(['reward_id']);
            $table->dropColumn(['reward_id', 'paid_price']);
        });
    }
};
