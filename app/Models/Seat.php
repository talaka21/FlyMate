<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Seat extends Model
{
     protected $fillable = [
        'flight_id',
        'seat_number',
        'class',
        'is_available',
    ];

    public function flight()
    {
        return $this->belongsTo(Flight::class);
    }
}
