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
        Schema::create('booking_types', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->enum('type', ['one_way', 'round_trip', 'multi_city']);
            $table->decimal('cancellation_fee_72h', 5, 2)->default(0);
            $table->decimal('cancellation_fee_24h', 5, 2)->default(20);
            $table->decimal('cancellation_fee_less_24h', 5, 2)->default(50);
            $table->integer('baggage_allowance')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('booking_types');
    }
};
