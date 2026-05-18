<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
public function up()
{
    Schema::create('report_images', function (Blueprint $table) {
        $table->id();

        // ربط الصورة بالبلاغ الأساسي للحقيبة المفقودة
        $table->foreignId('lost_baggage_report_id')
              ->constrained('lost_baggage_reports')
              ->onDelete('cascade');

        // ربط الصورة بالمستخدم اللي رفعها (سواء المسافر نفسه أو الموظف/الآدمين)
        $table->foreignId('uploaded_by')->constrained('users')->onDelete('cascade');

        // نوع الصورة: هل هي صورة الحقيبة، صورة الملصق/التاغ، أو صورة العثور عليها
        $table->enum('image_type', ['baggage', 'tag', 'found']);

        // رابط الصورة الكامل (CDN URL) والـ Key الداخلي للتخزين بالسيرفر
        $table->string('url');
        $table->string('storage_key');

        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('report_images');
    }
};
