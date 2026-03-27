<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Airline extends Model
{
    protected $fillable = [
        'name',
        'code',
        'logo',
        'contact_info',
        'is_active',
    ];

    public function flights()
    {
        return $this->hasMany(Flight::class);
    }
}
