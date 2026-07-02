<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BookingType extends Model
{
     use HasFactory;
    protected $fillable = [
        'name',
        'type',
        'cancellation_fee_72h',
        'cancellation_fee_24h',
        'cancellation_fee_less_24h',
        'baggage_allowance',
        'is_active',
    ];

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }
}
