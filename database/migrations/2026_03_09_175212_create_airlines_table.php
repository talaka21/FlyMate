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
        Schema::create('airlines', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code')->unique();
            $table->string('logo')->nullable();
            $table->string('hub_city')->nullable();        // Dubai, Istanbul...
            $table->string('tagline')->nullable();         // "World's Best Airline"
            $table->integer('baggage_kg')->default(23);    // 20, 23, 30, 35
            $table->decimal('rating', 2, 1)->default(0);  // 4.8, 4.5...
            $table->integer('destinations_count')->default(0);
            $table->json('facilities')->nullable();
            $table->string('contact_info')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('airlines');
    }
};
