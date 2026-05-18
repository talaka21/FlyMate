<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LostBaggageReport extends Model
{
    use HasFactory;

    protected $fillable = [
        'reference_number',
        'user_id',
        'flight_number',
        'departure_city',
        'arrival_city',
        'arrival_date',
        'airport_code',
        'baggage_type',
        'baggage_size',
        'baggage_color',
        'description',
        'distinctive_marks',
        'contact_phone',
        'contact_email',
        'delivery_address',
        'status',
        'admin_notes',
        'assigned_to'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function staff()
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }


public function statusHistory()
{
    return $this->hasMany(ReportStatusHistory::class, 'lost_baggage_report_id')->orderBy('created_at', 'desc');
}

    public function images()
    {
        return $this->hasMany(ReportImage::class, 'lost_baggage_report_id');
    }
}

