<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Airline extends Model
{
protected $fillable = [
    'name', 'code', 'hub_city', 'tagline', 'baggage_kg',
    'rating', 'destinations_count', 'facilities', 'contact_info', 'is_active'
];

protected $casts = [
    'facilities' => 'array', // ليتم قراءتها كمصفوفة فوراً
];

 
    public function flights()
    {
        return $this->hasMany(Flight::class);
    }
        public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
