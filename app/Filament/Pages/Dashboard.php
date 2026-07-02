<?php

namespace App\Filament\Pages;

use App\Models\Booking;
use App\Models\Payment;
use App\Models\User;
use App\Models\Flight;
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Pages\Dashboard\Concerns\HasFiltersForm;
use Filament\Forms\Form;
use Filament\Forms\Components\DatePicker;
use Filament\Actions\Action;
use Barryvdh\DomPDF\Facade\Pdf;

class Dashboard extends BaseDashboard
{
    use HasFiltersForm;

    public function filtersForm(Form $form): Form
    {
        return $form->schema([
            DatePicker::make('startDate')->label('From'),
            DatePicker::make('endDate')->label('To'),
        ]);
    }

    public function getHeaderActions(): array
    {
        return [
            Action::make('exportExcel')
                ->label('Export Excel')
                ->color('success')
                ->icon('heroicon-o-table-cells')
                ->action(fn() => (new \App\Exports\BookingsExport)->download()),

            Action::make('exportPdf')
                ->label('Export PDF')
                ->color('danger')
                ->icon('heroicon-o-document')
                ->action(function () {
                    $stats = $this->getStats();
                    $pdf = Pdf::loadView('reports.pdf', compact('stats'));
                    return response()->streamDownload(
                        fn() => print($pdf->output()),
                        'flymate-report.pdf'
                    );
                }),
        ];
    }

    public function getStats(): array
    {
        $dateFrom = $this->filters['startDate'] ?? null;
        $dateTo   = $this->filters['endDate'] ?? null;

        $query        = Booking::query();
        $paymentQuery = Payment::query();

        if ($dateFrom) {
            $query->whereDate('created_at', '>=', $dateFrom);
            $paymentQuery->whereDate('created_at', '>=', $dateFrom);
        }
        if ($dateTo) {
            $query->whereDate('created_at', '<=', $dateTo);
            $paymentQuery->whereDate('created_at', '<=', $dateTo);
        }

        $totalFlights     = Flight::count();
        $cancelledFlights = Flight::where('status', 'cancelled')->count();

        return [
            'total_bookings'    => $query->count(),
            'confirmed'         => (clone $query)->where('status', 'confirmed')->count(),
            'cancelled'         => (clone $query)->where('status', 'cancelled')->count(),
            'pending'           => (clone $query)->where('status', 'pending')->count(),
            'total_revenue'     => $paymentQuery->where('status', 'success')->sum('amount'),
            'total_passengers'  => User::where('role', 'passenger')->count(),
            'total_flights'     => $totalFlights,
            'cancelled_flights' => $cancelledFlights,
        ];
    }
}
