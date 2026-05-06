<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Airline extends Model
{
   protected $fillable = [
        'name',
        'code',
        'logo',
        'hub_city',
        'tagline',
        'baggage_kg',
        'rating',
        'destinations_count',
        'has_wifi',
        'has_lounge',
        'has_meals',
        'has_entertainment',
        'contact_info',
        'is_active',
    ];

    protected $casts = [
        'is_active'       => 'boolean',
        'has_wifi'        => 'boolean',
        'has_lounge'      => 'boolean',
        'has_meals'       => 'boolean',
        'has_entertainment' => 'boolean',
        'rating'          => 'float',
        'baggage_kg'      => 'integer',
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
