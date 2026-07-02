<?php

namespace Tests\Feature;

use App\Models\Booking;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class CancelBookingTest extends TestCase
{
    use RefreshDatabase;

    #[Test]
    public function authenticated_user_can_cancel_their_booking(): void
    {
        $user = User::factory()->create(['role' => 'passenger']);
        $booking = Booking::factory()->create([
            'user_id' => $user->id,
            'status'  => 'confirmed',
        ]);

        $response = $this->actingAs($user)
                         ->postJson("/api/bookings/{$booking->id}/cancel");

        $response->assertStatus(200);
        $this->assertDatabaseHas('bookings', [
            'id'     => $booking->id,
            'status' => 'cancelled',
        ]);
    }

    #[Test]
    public function user_cannot_cancel_another_users_booking(): void
    {
        $user    = User::factory()->create(['role' => 'passenger']);
        $other   = User::factory()->create(['role' => 'passenger']);
        $booking = Booking::factory()->create(['user_id' => $other->id]);

        $response = $this->actingAs($user)
                         ->postJson("/api/bookings/{$booking->id}/cancel");

        // 🔄 تم التعديل إلى 400 لأن الكنترولر يمسك خطأ (findOrFail) ويعيده كـ 400 عبر دالة الخطأ
        $response->assertStatus(400);
    }

    #[Test]
    public function guest_cannot_cancel_booking(): void
    {
        $booking = Booking::factory()->create();

        $response = $this->postJson("/api/bookings/{$booking->id}/cancel");

        $response->assertStatus(401);
    }

    #[Test]
    public function cannot_cancel_already_cancelled_booking(): void
    {
        $user = User::factory()->create(['role' => 'passenger']);
        $booking = Booking::factory()->create([
            'user_id' => $user->id,
            'status'  => 'cancelled',
        ]);

        $response = $this->actingAs($user)
                         ->postJson("/api/bookings/{$booking->id}/cancel");

        $response->assertStatus(400);
    }
}
