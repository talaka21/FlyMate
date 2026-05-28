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
             if (!Schema::hasColumn('bookings', 'cancellation_fee')) {
            $table->decimal('cancellation_fee', 8, 2)->default(0)->after('paid_price');
        }
        if (!Schema::hasColumn('bookings', 'refund_amount')) {
            $table->decimal('refund_amount', 8, 2)->nullable()->after('cancellation_fee');
        }
        if (!Schema::hasColumn('bookings', 'stripe_payment_id')) {
            $table->string('stripe_payment_id')->nullable()->after('refund_amount');
        }
        if (!Schema::hasColumn('bookings', 'reward_id')) {
            $table->foreignId('reward_id')->nullable()->constrained()->nullOnDelete()->after('stripe_payment_id');}
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['cancellation_fee', 'refund_amount', 'stripe_payment_id', 'reward_id']);
        });
    }
};
