<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
class Airport extends Model
{
     use HasFactory;

     protected $fillable = [
        'name',
        'iata_code',
        'city',
        'country',
        'terminals',
    ];

    public function originFlights()
    {
        return $this->hasMany(Flight::class, 'origin_airport_id');
    }

    public function destinationFlights()
    {
        return $this->hasMany(Flight::class, 'destination_airport_id');
    }
}
