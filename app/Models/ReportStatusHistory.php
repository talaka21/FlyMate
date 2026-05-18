<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReportStatusHistory extends Model
{
    use HasFactory;

    protected $table = 'report_status_history';

    protected $fillable = [
        'lost_baggage_report_id',
        'changed_by',
        'status',
        'comment'
    ];

    public function report()
    {
        return $this->belongsTo(LostBaggageReport::class, 'lost_baggage_report_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
