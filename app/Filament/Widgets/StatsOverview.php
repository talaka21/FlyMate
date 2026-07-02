<?php

namespace App\Filament\Widgets;

use App\Filament\Pages\Dashboard;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $stats = (new Dashboard)->getStats();

        $cancellationRate = $stats['total_flights'] > 0
            ? round(($stats['cancelled_flights'] / $stats['total_flights']) * 100, 1)
            : 0;

        return [
            // ── BOOKING OVERVIEW ──────────────────────────────
            Stat::make('Total Bookings', $stats['total_bookings'])
                ->description('All time')
                ->descriptionIcon('heroicon-m-ticket')
                ->color('primary'),

            Stat::make('Confirmed', $stats['confirmed'])
                ->description('Active bookings')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),

            Stat::make('Cancelled', $stats['cancelled'])
                ->description('Refunded or voided')
                ->descriptionIcon('heroicon-m-x-circle')
                ->color('danger'),

            Stat::make('Pending', $stats['pending'])
                ->description('Awaiting confirmation')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),

            // ── FINANCIAL & OPERATIONS ────────────────────────
            Stat::make('Total Revenue', '$' . number_format($stats['total_revenue'], 2))
                ->description('USD collected')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success'),

            Stat::make('Total Passengers', $stats['total_passengers'])
                ->description('Registered travellers')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('primary'),

            Stat::make('Total Flights', $stats['total_flights'])
                ->description('Scheduled routes')
                ->descriptionIcon('heroicon-m-paper-airplane')
                ->color('info'),

            Stat::make('Cancelled Flights', $stats['cancelled_flights'])
                ->description($cancellationRate . '% cancellation rate')
                ->descriptionIcon('heroicon-m-arrow-uturn-left')
                ->color('danger'),
        ];
    }
}
