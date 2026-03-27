<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FlightResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
     return [
            // Basic
            'id'                      => $this->id,
            'flight_number'           => $this->flight_number,
            'aircraftType'            => $this->aircraft_type,
            'totalSeat'               => $this->total_seats,
            'status'                  => $this->status,

            // Airline
            'airlineId'               => $this->airline->id ?? null,
            'airlineName'             => $this->airline->name ?? null,
            'airlineCode'             => $this->airline->code ?? null,

            // Airports
            'originAirportId'         => $this->originAirport->id ?? null,
            'destinationAirportId'    => $this->destinationAirport->id ?? null,
            'origin'                  => $this->originAirport->iata_code ?? null,
            'destination'             => $this->destinationAirport->iata_code ?? null,

            // Times
            'departureAt'             => $this->departure_at,
            'arrivalAt'               => $this->arrival_at,

            // Available Seats
            'availableSeatsFirst'     => $this->seats->where('class', 'first_class')->where('is_available', true)->count(),
            'availableSeatsBusiness' => $this->seats->where('class', 'business')->where('is_available', true)->count(),
            'availableSeatsEconomy'   => $this->seats->where('class', 'economy')->where('is_available', true)->count(),

            // Price
            'mockPrice'               => $this->prices->where('class', 'economy')->first()->base_price ?? 0,

            // All Prices
            'prices'                  => $this->prices->map(fn($p) => [
                'class'      => $p->class,
                'base_price' => $p->base_price,
            ]),
        ];
    }
}
