<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\Booking;
use App\Models\Flight;
use App\Models\Payment;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
             return [
            Stat::make('Total Passengers', User::where('role', 'passenger')->count())
                ->description('Registered passengers')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('primary'),

            Stat::make('Total Flights', Flight::count())
                ->description('Available flights')
                ->descriptionIcon('heroicon-m-paper-airplane')
                ->color('info'),

            Stat::make('Total Bookings', Booking::count())
                ->description('All reservations')
                ->descriptionIcon('heroicon-m-ticket')
                ->color('success'),

            Stat::make('Flights Today', Flight::whereDate('departure_at', today())->count())
                ->description('Departures scheduled today')
                ->descriptionIcon('heroicon-m-paper-airplane')
                ->color('info'),

            Stat::make('Average Ticket Price', '$' . number_format(Payment::avg('amount'), 2))
                ->description('Average booking payment')
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color('success'),

            Stat::make('Total Revenue', '$' . number_format(
                Payment::where('status', 'success')->sum('amount'), 2
            ))
                ->description('Total earnings')
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color('warning'),

            Stat::make('Pending Managers', User::where('role', 'manager')->where('status', 'pending')->count())
                ->description('Managers awaiting approval')
                ->descriptionIcon('heroicon-m-clock')
                ->color('danger'),
        ];

    }
}
