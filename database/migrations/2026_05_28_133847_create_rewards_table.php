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
        Schema::create('rewards', function (Blueprint $table) {
            $table->id();
            $table->string('type'); // نوع الميزة: free_weight, seat_change, lounge_access, ticket_discount
            $table->string('title'); // اسم المكافأة (مثال: 5 كيلو جرام مجاناً)
            $table->integer('points_cost'); // سعرها بالنقاط
            $table->integer('value')->default(0); // القيمة (مثل نسبة الخصم 20 أو الوزن 5)
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rewards');
    }
};
