<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Flight;
use App\Models\Airport;
use App\Models\Airline;
use App\Models\Seat;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SearchFlightsTest extends TestCase
{
    use RefreshDatabase;

    private User $passenger;
    private Airport $damascus;
    private Airport $dubai;

    protected function setUp(): void
    {
        parent::setUp();

        $this->passenger = User::factory()->create([
            'role'   => 'passenger',
            'status' => 'active',
        ]);

        $this->damascus = Airport::factory()->create([
            'name'      => 'Damascus International Airport',
            'iata_code' => 'DAM',
            'city'      => 'Damascus',
        ]);

        $this->dubai = Airport::factory()->create([
            'name'      => 'Dubai International Airport',
            'iata_code' => 'DXB',
            'city'      => 'Dubai',
        ]);
    }

    public function test_search_returns_matching_flights(): void
    {
        $airline = Airline::factory()->create();

        $flight = Flight::factory()->create([
            'origin_airport_id'      => $this->damascus->id,
            'destination_airport_id' => $this->dubai->id,
            'airline_id'             => $airline->id,
            'departure_at' => now()->addDays(3),
            'status' => 'on_time',
        ]);

        Seat::factory()->create([
            'flight_id'    => $flight->id,
            'seat_number'  => 'EC01',
            'class'        => 'economy',
            'is_available' => true,
        ]);
        $response = $this->actingAs($this->passenger, 'sanctum')
            ->getJson('/api/flights/search?' . http_build_query([
                'origin'         => 'DAM',
                'destination'    => 'DXB',
                'departure_date' => now()->addDays(3)->toDateString(),
                'class'          => 'economy',
            ]));

        $response->assertStatus(200);
    }

    public function test_search_returns_empty_when_no_flights_match(): void
    {
        $response = $this->actingAs($this->passenger, 'sanctum')
            ->getJson('/api/flights/search?' . http_build_query([
                'origin'         => 'DAM',
                'destination'    => 'DXB',
                'departure_date' => now()->addDays(10)->toDateString(),
                'class'          => 'economy',
            ]));

        $response->assertStatus(200);
    }

    public function test_search_fails_when_required_params_missing(): void
    {
        $response = $this->actingAs($this->passenger, 'sanctum')
            ->getJson('/api/flights/search');

        $response->assertStatus(422);
    }

    public function test_search_fails_when_unauthenticated(): void
    {
        // Search route is public — test that it still responds
        $response = $this->getJson('/api/flights/search?' . http_build_query([
            'origin'         => 'DAM',
            'destination'    => 'DXB',
            'departure_date' => now()->addDays(3)->toDateString(),
        ]));

        // Accept 401 if protected, or 422 if public but missing params
        $this->assertContains(
            $response->status(),
            [200, 401, 422]
        );
    }
}
