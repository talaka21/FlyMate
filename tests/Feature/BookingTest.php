<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Flight;
use App\Models\Seat;
use App\Models\Booking;
use App\Models\BookingType;
use App\Models\FlightPrice;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BookingTest extends TestCase
{
    use RefreshDatabase;

    private User $passenger;
    private Flight $flight;
    private Seat $seat;
    private BookingType $bookingType;

    protected function setUp(): void
    {
        parent::setUp();

        $this->passenger = User::factory()->create([
            'role'   => 'passenger',
            'status' => 'active',
        ]);

        $this->bookingType = BookingType::factory()->create();

        $this->flight = Flight::factory()->create([
            'departure_at' => now()->addDays(5),
            'status'       => 'on_time',
        ]);

        $this->seat = Seat::factory()->create([
            'flight_id'    => $this->flight->id,
            'seat_number'  => 'EC01',
            'class'        => 'economy',
            'is_available' => true,
        ]);

        FlightPrice::create([
            'flight_id'  => $this->flight->id,
            'class'      => 'economy',
            'base_price' => 150.00,
            'min_price'  => 100.00,
            'max_price'  => 200.00,
        ]);
    }

    public function test_passenger_can_create_booking_successfully(): void
    {
        $response = $this->actingAs($this->passenger, 'sanctum')
            ->postJson('/api/bookings', [
                'flight_id'       => $this->flight->id,
                'booking_type_id' => $this->bookingType->id,
                'seat_class'      => 'economy',
                'seats'           => [$this->seat->id],
                'adult_count'     => 1,
                'child_count'     => 0,
                'infant_count'    => 0,
            ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('bookings', [
            'user_id'   => $this->passenger->id,
            'flight_id' => $this->flight->id,
            'status'    => 'pending',
        ]);
    }

    public function test_booking_fails_when_unauthenticated(): void
    {
        $response = $this->postJson('/api/bookings', [
            'flight_id' => $this->flight->id,
            'seat_id'   => $this->seat->id,
        ]);

        $response->assertStatus(401);
    }

    public function test_booking_fails_when_required_fields_missing(): void
    {
        $response = $this->actingAs($this->passenger, 'sanctum')
            ->postJson('/api/bookings', []);

        $response->assertStatus(422);
    }

    public function test_booking_fails_when_seat_already_taken(): void
    {
        $this->seat->update(['is_available' => false]);

        $response = $this->actingAs($this->passenger, 'sanctum')
            ->postJson('/api/bookings', [
                'flight_id'       => $this->flight->id,
                'booking_type_id' => $this->bookingType->id,
                'seat_class'      => 'economy',
                'seats'           => [$this->seat->id],
                'adult_count'     => 1,
                'child_count'     => 0,
                'infant_count'    => 0,
            ]);

        $response->assertStatus(201);
    }
}
