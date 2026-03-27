<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Booking extends Model
{
    protected $fillable = [
        'boarding_code',
        'user_id',
        'flight_id',
        'seat_id',
        'booking_type_id',
        'seat_class',
        'status',
        'total_price',
        'adult_count',
        'child_count',
        'infant_count'
    ];

    const STATUS_PENDING = 'pending';
    const STATUS_CONFIRMED = 'confirmed';
    const STATUS_CANCELLED = 'cancelled';

    // دالة توليد كود بوردينج تلقائي عند إنشاء الحجز
    protected static function booted()
    {
        static::creating(function ($booking) {
            // إذا لم يكن الكود موجوداً أصلاً، قم بتوليده
            if (!$booking->boarding_code) {
                $booking->boarding_code = 'FM-' . strtoupper(Str::random(8));
            }
        });
    }
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function flight()
    {
        return $this->belongsTo(Flight::class);
    }

    // إضافة علاقة المقعد لكي يعمل الـ Resource بدون أخطاء
    public function seat()
    {
        return $this->belongsTo(Seat::class);
    }

    public function bookingType()
    {
        return $this->belongsTo(BookingType::class);
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }
}
