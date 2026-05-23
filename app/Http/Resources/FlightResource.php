<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FlightResource extends JsonResource
{
   public function toArray(Request $request): array
{
    return [
        'id'                     => $this->id,
        'flight_number'          => $this->flight_number,
        'aircraftType'           => $this->aircraft_type,
        'totalSeat'              => $this->total_seats,
        'status'                 => $this->status,
        'airlineId'              => $this->airline_id,
        'airlineName'            => $this->airline->name ?? '',
        'airlineCode'            => $this->airline->code ?? '',
        'originAirportId'        => $this->origin_airport_id,
        'destinationAirportId'   => $this->destination_airport_id,
        'origin'                 => $this->originAirport->iata_code ?? '',
        'destination'            => $this->destinationAirport->iata_code ?? '',
        'departureAt'            => $this->departure_at,
        'arrivalAt'              => $this->arrival_at,

        'prices'                 => $this->prices->map(function($price) {
            return [
                'class' => $price->class,
                'price' => (float) $price->base_price
            ];
        }),
        'availableSeatsFirst'    => $this->seats()->where('class', 'first_class')->where('is_available', true)->count(),
        'availableSeatsBusiness' => $this->seats()->where('class', 'business')->where('is_available', true)->count(),
        'availableSeatsEconomy'  => $this->seats()->where('class', 'economy')->where('is_available', true)->count(),
    ];
}
}
