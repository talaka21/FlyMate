<?php

namespace App\Filament\Resources\FlightPriceResource\Pages;

use App\Filament\Resources\FlightPriceResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListFlightPrices extends ListRecords
{
    protected static string $resource = FlightPriceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
