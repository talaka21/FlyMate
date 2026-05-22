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
            'totalSeat'              => $table->total_seats ?? $this->total_seats,
            'status'                 => $this->status,
            'airlineId'              => $this->airline_id,
            'airlineName'            => $this->airline->name ?? $this->airline_name, // حسب ربط الموديل عندك
            'airlineCode'            => $this->airline->code ?? $this->airline_code,
            'originAirportId'        => $this->origin_airport_id,
            'destinationAirportId'   => $this->destination_airport_id,
            'origin'                 => $this->originAirport->iata_code ?? $this->origin, // أو الاختصار مباشرة
            'destination'            => $this->destinationAirport->iata_code ?? $this->destination,
            'departureAt'            => $this->departure_at,
            'arrivalAt'              => $this->arrival_at,

            'availableSeatsFirst'    => (int) $this->available_seats_first,
            'availableSeatsBusiness' => (int) $this->available_seats_business,
            'availableSeatsEconomy'  => (int) $this->available_seats_economy,
            'mockPrice'              => (float) $this->mock_price,

            'prices'                 => [
                (float) $this->mock_price
            ]
        ];
    }
}
