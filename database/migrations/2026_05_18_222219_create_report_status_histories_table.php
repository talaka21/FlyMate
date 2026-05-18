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
    Schema::create('report_status_history', function (Blueprint $table) {
        $table->id();

        // ربط السجل بالبلاغ الأساسي للحقيبة المفقودة
        $table->foreignId('lost_baggage_report_id')
              ->constrained('lost_baggage_reports')
              ->onDelete('cascade');

        // الموظف أو المستخدم الذي قام بتحديث الحالة
        $table->foreignId('changed_by')->constrained('users')->onDelete('cascade');

        // الحالة الجديدة التي تم الانتقال إليها
        $table->enum('status', [
            'pending_review',
            'sent_to_airport',
            'searching',
            'found',
            'in_delivery',
            'delivered',
            'closed'
        ]);

        // ملاحظات اختيارية يكتبها الموظف لشرح التحديث (تظهر للمسافر)
        $table->text('comment')->nullable();

        // سنعتمد على التوقيت الافتراضي لمعرفة متى حدث التغيير بدقة
        $table->timestamps();

        // إضافة Index لتسريع عملية جلب الخط الزمني للبلاغ
        $table->index(['lost_baggage_report_id', 'created_at']);
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('report_status_histories');
    }
};
