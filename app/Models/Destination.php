<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Destination extends Model
{
    protected $fillable = [
        'name', 'country', 'iata_code', 'image',
        'tagline', 'description', 'avg_temperature',
        'best_months', 'is_popular'
    ];

    protected $casts = [
        'is_popular' => 'boolean',
        'avg_temperature' => 'float',
    ];

    public function neighborhoods()
    {
        return $this->hasMany(DestinationNeighborhood::class);
    }
}
