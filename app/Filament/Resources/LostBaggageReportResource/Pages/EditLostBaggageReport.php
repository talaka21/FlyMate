<?php

namespace App\Filament\Resources\LostBaggageReportResource\Pages;

use App\Filament\Resources\LostBaggageReportResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditLostBaggageReport extends EditRecord
{
    protected static string $resource = LostBaggageReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
