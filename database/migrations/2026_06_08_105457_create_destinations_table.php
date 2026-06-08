<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('destinations', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('country');
            $table->string('iata_code', 3)->nullable(); // DAM, DXB...
            $table->string('image')->nullable();
            $table->string('tagline')->nullable();      // "The city of the future"
            $table->text('description')->nullable();
            $table->decimal('avg_temperature', 4, 1)->nullable();
            $table->string('best_months')->nullable();  // "Sep,Oct,Nov,Mar,Apr"
            $table->boolean('is_popular')->default(false);
            $table->timestamps();
        });

        Schema::create('destination_neighborhoods', function (Blueprint $table) {
            $table->id();
            $table->foreignId('destination_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('image')->nullable();
            $table->json('tags')->nullable();           // ["Beach", "Luxury", "Family"]
            $table->text('description')->nullable();
            $table->timestamps();
        });

        Schema::create('destination_spots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('neighborhood_id')->constrained('destination_neighborhoods')->cascadeOnDelete();
            $table->string('name');
            $table->string('subtitle')->nullable();
            $table->string('icon')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('destination_spots');
        Schema::dropIfExists('destination_neighborhoods');
        Schema::dropIfExists('destinations');
    }
};
