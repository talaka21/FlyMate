<?php

namespace App\Filament\Resources\BookingTypeResource\Pages;

use App\Filament\Resources\BookingTypeResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListBookingTypes extends ListRecords
{
    protected static string $resource = BookingTypeResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
