<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DestinationSpot extends Model
{
    protected $fillable = [
        'neighborhood_id', 'name', 'subtitle', 'icon'
    ];

    public function neighborhood()
    {
        return $this->belongsTo(DestinationNeighborhood::class);
    }
}
