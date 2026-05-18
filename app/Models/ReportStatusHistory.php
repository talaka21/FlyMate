<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReportStatusHistory extends Model
{
    use HasFactory;

    // تحديد اسم الجدول يدوياً لأن لارافيل قد يجمعه بصيغة مختلفة
    protected $table = 'report_status_history';

    protected $fillable = [
        'lost_baggage_report_id',
        'changed_by',
        'status',
        'comment'
    ];

    // التحديث ينتمي لبلاغ معين
    public function report()
    {
        return $this->belongsTo(LostBaggageReport::class, 'lost_baggage_report_id');
    }

    // التحديث تم بواسطة مستخدم/موظف معين
    public function user()
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
