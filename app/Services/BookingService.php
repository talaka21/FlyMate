<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\Flight;
use App\Models\FlightPrice;
use App\Mail\BookingConfirmationMail;
use App\Mail\BookingCancelledMail;
use App\Mail\BookingRescheduledMail;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Exception;

class BookingService
{
    public function getAllUserBookings($userId)
    {
        return Booking::with([
            'flight.airline',
            'flight.originAirport',
            'flight.destinationAirport',
            'bookingType'
        ])
            ->where('user_id', $userId)
            ->latest()
            ->get();
    }
    public function createBooking(array $data, $user)
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($data, $user) {
            $priceInfo = $this->getFlightPrice($data['flight_id'], $data['seat_class']);

            if (!$priceInfo) {
                throw new \Exception(__('bookings.no_seats'));
            }

            $createdBookings = [];
            $seats = $data['seats'] ?? [$data['seat_id']];

            foreach ($seats as $seatId) {
                $booking = Booking::create([
                    'reference'       => 'FM-' . strtoupper(\Illuminate\Support\Str::random(8)),
                    'user_id'         => $user->id,
                    'flight_id'       => $data['flight_id'],
                    'booking_type_id' => $data['booking_type_id'],
                    'seat_class'      => $data['seat_class'],
                    'seat_id'         => $seatId,
                    'status'          => Booking::STATUS_PENDING,
                    'total_price'     => $priceInfo->base_price, // سعر المقعد الواحد
                    'boarding_code'   => 'BC-' . strtoupper(\Illuminate\Support\Str::random(6)),
                    'adult_count'     => $data['adult_count'],
                    'child_count'     => $data['child_count'] ?? 0,
                    'infant_count'    => $data['infant_count'] ?? 0,
                ]);

                $qrCode = 'data:image/svg+xml;base64,' . base64_encode(
                    \SimpleSoftwareIO\QrCode\Facades\QrCode::format('svg')->size(200)->generate("https://flymate.com/verify/" . $booking->boarding_code)
                );

                \Illuminate\Support\Facades\Mail::to($user->email)->send(new \App\Mail\BoardingPassMail($booking, $qrCode));
                sleep(2);
                $createdBookings[] = $booking;
            }
            return $createdBookings;
        });
    }

    public function cancelBooking(Booking $booking)
    {
        if (!in_array($booking->status, [Booking::STATUS_PENDING, Booking::STATUS_CONFIRMED])) {
            throw new Exception(__('bookings.cannot_cancel'));
        }

        $booking->update(['status' => Booking::STATUS_CANCELLED]);

        Mail::to($booking->user->email)->send(new BookingCancelledMail($booking));

        return $booking;
    }

    public function rescheduleBooking(Booking $booking, array $data)
    {
        if ($booking->status !== Booking::STATUS_CONFIRMED) {
            throw new Exception(__('bookings.cannot_reschedule'));
        }

        $flight = Flight::find($booking->flight_id);
        if (now()->diffInHours($flight->departure_time, false) < 24) {
            throw new Exception(__('bookings.reschedule_too_late'));
        }

        $newPrice = $this->getFlightPrice($data['new_flight_id'], $booking->seat_class);
        $fareDifference = $newPrice ? max(0, $newPrice->base_price - $booking->total_price) : 0;

        $booking->update(['flight_id' => $data['new_flight_id']]);

        Mail::to($booking->user->email)->send(new BookingRescheduledMail($booking));

        return ['booking' => $booking, 'fare_difference' => $fareDifference];
    }

    public function upgradeBooking(Booking $booking, $newClass)
    {
        if ($booking->status !== Booking::STATUS_CONFIRMED) {
            throw new Exception(__('bookings.cannot_upgrade'));
        }

        $flight = Flight::find($booking->flight_id);
        if (now()->diffInHours($flight->departure_time, false) < 12) {
            throw new Exception(__('bookings.upgrade_too_late'));
        }

        $newPrice = $this->getFlightPrice($booking->flight_id, $newClass);
        if (!$newPrice) {
            throw new Exception(__('bookings.same_class'));
        }

        $priceDifference = max(0, $newPrice->base_price - $booking->total_price);

        $booking->update([
            'seat_class'  => $newClass,
            'total_price' => $newPrice->base_price,
        ]);

        return ['booking' => $booking, 'price_difference' => $priceDifference];
    }

    public function getFlightPrice($flightId, $class)
    {
        return FlightPrice::where('flight_id', $flightId)
            ->where('class', $class)
            ->first();
    }
    public function sendBoardingPassEmail($booking)
    {
        $qrCode = 'data:image/svg+xml;base64,' . base64_encode(
            \SimpleSoftwareIO\QrCode\Facades\QrCode::format('svg')
                ->size(200)
                ->generate("https://flymate.com/verify-boarding/" . $booking->boarding_code)
        );

        \Illuminate\Support\Facades\Mail::to($booking->user->email)
            ->send(new \App\Mail\BoardingPassMail($booking, $qrCode));

        return $booking;
    }
}
