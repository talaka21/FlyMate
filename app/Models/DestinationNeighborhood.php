<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DestinationNeighborhood extends Model
{
    protected $fillable = [
        'destination_id', 'name', 'image', 'tags', 'description'
    ];

    protected $casts = [
        'tags' => 'array',
    ];

    public function destination()
    {
        return $this->belongsTo(Destination::class);
    }

    public function spots()
    {
        return $this->hasMany(DestinationSpot::class, 'neighborhood_id');
    }
}
