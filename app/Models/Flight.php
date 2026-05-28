<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;
class Flight extends Model
{
    protected $fillable = [
        'flight_number',
        'airline_id',
        'origin_airport_id',
        'destination_airport_id',
        'departure_at',
        'arrival_at',
        'aircraft_type',
        'total_seats',
        'status',
        'frequency',
    ];

    protected $casts = [
        'departure_at' => 'datetime',
        'arrival_at'   => 'datetime',
    ];

    public function getCurrentPrice()
    {
        // 1. جلب السعر الأساسي للرحلة (عدلي اسم الحقل 'price' حسب شو مسميتيه بقاعدة البيانات عندك)
        $basePrice = $this->price;

        // 2. حساب الوقت المتبقي للإقلاع بالساعات
        // (تأكدي أن اسم حقل وقت الإقلاع هو 'departure_time' أو عدليه لحقلك الحالي)
        $hoursToDeparture = Carbon::now()->diffInHours(Carbon::parse($this->departure_time), false);

        // 3. حساب نسبة إشغال الطائرة (المقاعد المحجوزة المدفوعة / إجمالي المقاعد)
        // افترضنا أن عندكِ علاقة للحجوزات اسمها bookings وإجمالي مقاعد الطائرة اسمه total_seats
        $bookedSeatsCount = $this->bookings()->where('status', 'paid')->count();
        $totalSeats = $this->total_seats ?? 150; // إذا مو محددة الافتراضي 150 مقعد مثلاً

        $occupancyRate = $totalSeats > 0 ? ($bookedSeatsCount / $totalSeats) * 100 : 0;

        // 4. تطبيق الشروط: إذا باقي أقل من 48 ساعة، ونسبة الإشغال أقل من 70%، والرحلة لسه ما أقلعت (أكبر من 0)
        if ($hoursToDeparture > 0 && $hoursToDeparture <= 48 && $occupancyRate < 70) {
            // تطبيق خصم اللحظة الأخيرة 25%
            return $basePrice * 0.75;
        }

        // إذا الشروط ما انطبقت، بيرجع السعر الطبيعي بدون أي خصم
        return $basePrice;
    }

    public function airline()
    {
        return $this->belongsTo(Airline::class);
    }

    public function originAirport()
    {
        return $this->belongsTo(Airport::class, 'origin_airport_id');
    }

    public function destinationAirport()
    {
        return $this->belongsTo(Airport::class, 'destination_airport_id');
    }

    public function prices()
    {
        return $this->hasMany(FlightPrice::class);
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function seats()
    {
        return $this->hasMany(Seat::class);
    }

    public function schedules()
    {
        return $this->hasMany(Schedule::class);
    }

    public function getDurationLabelAttribute(): string
    {
        $minutes = $this->departure_at->diffInMinutes($this->arrival_at);
        $h = intdiv($minutes, 60);
        $m = $minutes % 60;
        return $m > 0 ? "{$h}h {$m}m" : "{$h}h";
    }

}
