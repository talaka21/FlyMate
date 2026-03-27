<?php

namespace App\Filament\Pages;

use App\Models\Booking;
use App\Models\Payment;
use App\Models\User;
use App\Models\Flight;
use Filament\Pages\Page;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Form;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Section;
use Barryvdh\DomPDF\Facade\Pdf;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\BookingsExport;

class Reports extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';
    protected static ?string $navigationGroup = 'System';
    protected static string $view = 'filament.pages.reports';

    public ?string $date_from = null;
    public ?string $date_to = null;

    public static function canAccess(): bool
    {
        return auth()->user()->role === 'admin';
    }

    public function form(Form $form): Form
    {
        return $form->schema([
            Section::make('Filter by Date')->schema([
                DatePicker::make('date_from')->label('From'),
                DatePicker::make('date_to')->label('To'),
            ])->columns(2),
        ]);
    }

    public function getStats(): array
    {
        $query = Booking::query();
        $paymentQuery = Payment::query();

        if ($this->date_from) {
            $query->whereDate('created_at', '>=', $this->date_from);
            $paymentQuery->whereDate('created_at', '>=', $this->date_from);
        }
        if ($this->date_to) {
            $query->whereDate('created_at', '<=', $this->date_to);
            $paymentQuery->whereDate('created_at', '<=', $this->date_to);
        }

        return [
            'total_bookings'    => $query->count(),
            'confirmed'         => $query->where('status', 'confirmed')->count(),
            'cancelled'         => (clone $query)->where('status', 'cancelled')->count(),
            'pending'           => (clone $query)->where('status', 'pending')->count(),
            'total_revenue'     => $paymentQuery->where('status', 'success')->sum('amount'),
            'total_passengers'  => User::where('role', 'passenger')->count(),
            'total_flights'     => Flight::count(),
            'cancelled_flights' => Flight::where('status', 'cancelled')->count(),
        ];
    }

  public function exportExcel()
{
    return (new \App\Exports\BookingsExport)->download();
}
    public function exportPdf()
    {
        $stats = $this->getStats();
        $pdf = Pdf::loadView('reports.pdf', compact('stats'));
        return response()->streamDownload(
            fn () => print($pdf->output()),
            'flymate-report.pdf'
        );
    }
}
