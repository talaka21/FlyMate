<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;

class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */



    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'employee_id',
        'status',
        'mfa_code',
        'mfa_expires_at',
        'fcm_token',
        'loyalty_points',
    ];

    const ROLE_ADMIN = 'admin';
const ROLE_MANAGER = 'manager';
const ROLE_PASSENGER = 'passenger';

const STATUS_ACTIVE = 'active';
const STATUS_PENDING = 'pending';
const STATUS_BANNED = 'banned';
    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'mfa_code',
    ];

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function isManager(): bool
    {
        return $this->role === 'manager';
    }

    public function isPassenger(): bool
    {
        return $this->role === 'passenger';
    }

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function isPending(): bool
    {
        return $this->status === 'pending';
    }
    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }


    public function canAccessPanel(Panel $panel): bool
    {
        if ($panel->getId() === 'admin') {
            return in_array($this->role, ['admin', 'manager'])
                && $this->status === 'active';
        }

        return false;
    }

    public function bookings()
{
    // افترضت هنا أن اسم المودل عندك هو Booking
    return $this->hasMany(\App\Models\Booking::class);
}
}
