<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = [
        'booking_id',
        'amount',
        'payment_method',
        'status',
        'transaction_id',
        'user_id',
    ];

    const STATUS_SUCCESS = 'success';
    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }
}
