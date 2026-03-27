<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PassengerDetail extends Model
{
     protected $fillable = [
        'user_id',
        'date_of_birth',
        'phone',
        'nationality',
        'passport_number',
        'profile_photo',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
