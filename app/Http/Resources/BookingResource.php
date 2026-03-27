<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class BookingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        // 1. توليد صورة الـ QR لمرة واحدة فقط وبشكل احترافي
        $qrCodeImage = QrCode::format('svg')
            ->size(200)
            ->errorCorrection('H')
            ->color(26, 115, 232) // لون أزرق FlyMate التقني
            ->generate("https://flymate.com/verify-boarding/" . $this->boarding_code);

        $base64Qr = 'data:image/svg+xml;base64,' . base64_encode($qrCodeImage);

        return [
            'booking_id'     => $this->id,
            'reference'      => $this->reference, // مهم جداً للبحث
            'boarding_code'  => $this->boarding_code,
            'status'         => $this->status,
            'total_price'    => $this->total_price, // السعر اللي سحبناه ديناميكياً
            'airline_name'  => $this->flight?->airline?->name,
            // بيانات المسافر
            'passenger_name' => $this->user?->name,

            // بيانات الرحلة
            'flight_number'  => $this->flight?->flight_number,
            'aircraft_type'  => $this->flight?->aircraft?->type,
            'departure_at'   => $this->flight?->departure_at?->format('Y-m-d H:i'),
            'arrival_at'     => $this->flight?->arrival_at?->format('Y-m-d H:i'),

            // بيانات المسار
            'from'           => $this->flight?->originAirport?->city,
            'from_code' => $this->flight?->originAirport?->iata_code,
            'to'             => $this->flight?->destinationAirport?->city,
            'to_code' => $this->flight?->destinationAirport?->iata_code,

            // بيانات المقعد
            'seat_number'    => $this->seat?->seat_number,
            'class'          => ucfirst($this->seat_class),
            'gate'           => $this->flight?->gate ?? 'TBA',

            // حقل الـ QR 
            'qr_code_base64' => $base64Qr,
        ];
    }
}
