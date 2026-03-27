<?php

namespace App\Exports;

use App\Models\Booking;
use OpenSpout\Writer\XLSX\Writer;
use OpenSpout\Common\Entity\Row;

class BookingsExport
{
    public function download()
    {
        $filePath = storage_path('app/bookings.xlsx');

        $writer = new Writer();
        $writer->openToFile($filePath);

        // Header
        $writer->addRow(Row::fromValues([
            'Reference', 'Passenger', 'Flight', 'Class', 'Status', 'Created At'
        ]));

        // Data
        $bookings = Booking::with(['user', 'flight'])->get();
        foreach ($bookings as $booking) {
            $writer->addRow(Row::fromValues([
                $booking->reference ?? 'N/A',
                $booking->user->name ?? 'N/A',
                $booking->flight->flight_number ?? 'N/A',
                $booking->seat_class ?? 'N/A',
                $booking->status ?? 'N/A',
                $booking->created_at->format('Y-m-d'),
            ]));
        }

        $writer->close();

        return response()->download($filePath, 'bookings.xlsx')->deleteFileAfterSend();
    }
}
