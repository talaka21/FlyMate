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
        Schema::create('lost_baggage_reports', function (Blueprint $table) {
            $table->id(); // سنعتمد على BigIncrements أو UUID حسب تهيئة مشروعكم، الافتراضي id يحفي بالغرض
            $table->string('reference_number')->unique(); // e.g. FML-8324917

            // ربط البلاغ بالمستخدم (المسافر)
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');

            // بيانات الرحلة والوجهة
            $table->string('flight_number'); // e.g. FM-101
            $table->string('departure_city');
            $table->string('arrival_city');
            $table->date('arrival_date');
            $table->string('airport_code'); // IATA code e.g. CAI

            // مواصفات الحقيبة
            $table->enum('baggage_type', ['suitcase', 'backpack', 'hand_bag', 'other']);
            $table->enum('baggage_size', ['small', 'medium', 'large']);
            $table->string('baggage_color');
            $table->text('description'); // تفاصيل إضافية (الحد الأدنى 20 حرف بالـ Validation لاحقاً)
            $table->string('distinctive_marks')->nullable();

            // معلومات التواصل والتسليم
            $table->string('contact_phone');
            $table->string('contact_email');
            $table->string('delivery_address')->nullable();

            // حالة البلاغ (الافتراضية pending_review)
            $table->enum('status', [
                'pending_review',
                'sent_to_airport',
                'searching',
                'found',
                'in_delivery',
                'delivered',
                'closed'
            ])->default('pending_review');

            // حقول خاصة بالموظفين والإدارة
            $table->text('admin_notes')->nullable();
            $table->foreignId('assigned_to')->nullable()->constrained('users')->onDelete('set null');

            $table->timestamps();

            // إضافة Indexes لسرعة البحث والاستعلام كما أوصى الملف
            // مررنا اسماً مختصراً للـ Index كبارامتر ثانٍ لحل مشكلة الـ 64 حرفاً
            $table->index(['user_id', 'status', 'airport_code', 'flight_number'], 'lbr_search_idx');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('lost_baggage_reports');
    }
};
