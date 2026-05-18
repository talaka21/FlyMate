<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReportImage extends Model
{
    use HasFactory;

    protected $fillable = [
        'lost_baggage_report_id',
        'uploaded_by',
        'image_type',
        'url',
        'storage_key'
    ];

    // الصورة تنتمي لبلاغ حقيبة معين
    public function report()
    {
        return $table->belongsTo(LostBaggageReport::class, 'lost_baggage_report_id');
    }

    // الصورة تنتمي للمستخدم الذي رفعها
    public function uploader()
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }
}
