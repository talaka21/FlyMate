<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Schedule extends Model
{
     protected $fillable = [
        'flight_id',
        'origin_airport_id',
        'destination_airport_id',
        'departure_time',
        'arrival_time',
        'days_of_week',
        'valid_from',
        'valid_until',
        'status',
    ];

    protected $casts = [
        'days_of_week' => 'array',
    ];

    public function flight()
    {
        return $this->belongsTo(Flight::class);
    }
}
