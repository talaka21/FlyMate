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
        Schema::create('flights', function (Blueprint $table) {
            $table->id();
            $table->string('flight_number')->unique();
            $table->foreignId('airline_id')->constrained()->cascadeOnDelete();
            $table->foreignId('origin_airport_id')->constrained('airports')->cascadeOnDelete();
            $table->foreignId('destination_airport_id')->constrained('airports')->cascadeOnDelete();
            $table->dateTime('departure_at');
            $table->dateTime('arrival_at');
            $table->string('aircraft_type')->nullable();
            $table->integer('total_seats');
            $table->integer('available_seats');
            $table->integer('available_seats_first');
            $table->integer('available_seats_business');
            $table->integer('available_seats_economy');
            $table->decimal('mock_price', 8, 2);
            $table->string('frequency')->default('daily');
            $table->enum('status', ['on_time', 'delayed', 'cancelled'])->default('on_time');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('flights');
    }
};
