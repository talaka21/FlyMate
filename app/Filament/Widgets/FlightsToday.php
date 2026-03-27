<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use App\Models\Booking;

class FlightsToday extends ChartWidget
{
    protected static ?string $heading = 'Monthly Bookings';
    protected int|string|array $columnSpan = 'full';

    protected function getData(): array
    {
        $data = [];
        for ($i = 1; $i <= 12; $i++) {
            $data[] = Booking::whereMonth('created_at', $i)->count();
        }

        return [
            'datasets' => [[
                'label' => 'Bookings',
                'data'  => $data,
            ]],
            'labels' => ['Jan','Feb','Mar','Apr','May','Jun',
                         'Jul','Aug','Sep','Oct','Nov','Dec'],
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
