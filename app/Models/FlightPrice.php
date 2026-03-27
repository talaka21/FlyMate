<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FlightPrice extends Model
{
    protected $fillable = [
        'flight_id',
        'class',
        'base_price',
        'min_price',
        'max_price',
    ];

    public function flight()
    {
        return $this->belongsTo(Flight::class);
    }
}
