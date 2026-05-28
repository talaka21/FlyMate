<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Reward extends Model
{
   protected $fillable = ['type', 'title', 'points_cost', 'value', 'is_active'];

    // العلاقة: المكافأة الواحدة يمكن أن تكون مستخدمة في أكثر من حجز
    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }
}
