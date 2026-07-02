<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_passenger_can_register_with_valid_data(): void
    {
        $response = $this->postJson('/api/register/passenger', [
            'name'                  => 'Tala Kaakarli',
            'email'                 => 'tala@flymate.com',
            'password'              => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('users', [
            'email' => 'tala@flymate.com',
        ]);
    }

    public function test_registration_fails_when_email_already_exists(): void
    {
        User::factory()->create(['email' => 'tala@flymate.com']);

        $response = $this->postJson('/api/register/passenger', [
            'name'                  => 'Tala Kaakarli',
            'email'                 => 'tala@flymate.com',
            'password'              => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['email']);
    }

    public function test_registration_fails_when_password_confirmation_does_not_match(): void
    {
        $response = $this->postJson('/api/register/passenger', [
            'name'                  => 'Tala Kaakarli',
            'email'                 => 'tala@flymate.com',
            'password'              => 'password123',
            'password_confirmation' => 'wrong_password',
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['password']);
    }

    public function test_registration_fails_when_required_fields_are_missing(): void
    {
        $response = $this->postJson('/api/register/passenger', []);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['name', 'email', 'password']);
    }

    public function test_passenger_can_login_with_valid_credentials(): void
    {
        User::factory()->create([
            'email'    => 'tala@flymate.com',
            'password' => bcrypt('password123'),
            'role'     => 'passenger',
            'status'   => 'active',
        ]);

        $response = $this->postJson('/api/login', [
            'email'    => 'tala@flymate.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200);
    }

    public function test_login_fails_with_wrong_password(): void
    {
        User::factory()->create([
            'email'    => 'tala@flymate.com',
            'password' => bcrypt('correct_password'),
        ]);

        $response = $this->postJson('/api/login', [
            'email'    => 'tala@flymate.com',
            'password' => 'wrong_password',
        ]);

        $response->assertStatus(401);
    }

    public function test_login_fails_when_account_is_banned(): void
    {
        User::factory()->create([
            'email'    => 'banned@flymate.com',
            'password' => bcrypt('password123'),
            'status'   => 'banned',
        ]);

        $response = $this->postJson('/api/login', [
            'email'    => 'banned@flymate.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(403);
    }

    public function test_login_fails_when_fields_are_empty(): void
    {
        $response = $this->postJson('/api/login', []);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['email', 'password']);
    }

    public function test_authenticated_user_can_logout(): void
    {
        $user = User::factory()->create();

        $token = $user->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
                         'Authorization' => 'Bearer ' . $token,
                     ])
                         ->postJson('/api/logout');

        $response->assertStatus(200);
    }
}
