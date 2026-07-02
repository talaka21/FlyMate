<?php

namespace App\Filament\Resources\LostBaggageReportResource\Pages;

use App\Filament\Resources\LostBaggageReportResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListLostBaggageReports extends ListRecords
{
    protected static string $resource = LostBaggageReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
