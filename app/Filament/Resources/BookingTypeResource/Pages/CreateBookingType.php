<?php

namespace App\Filament\Resources\BookingTypeResource\Pages;

use App\Filament\Resources\BookingTypeResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateBookingType extends CreateRecord
{
    protected static string $resource = BookingTypeResource::class;
}
