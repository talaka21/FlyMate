@component('mail::message')
# Get Ready for Takeoff! ✈️

Hi **{{ $booking->user->name }}**,

Great news! Your booking is confirmed and your seat is waiting for you. We’re excited to have you on board.

@component('mail::panel')
<div style="text-align: center; margin-bottom: 10px;">
    <strong style="font-size: 1.2em;">{{ $booking->flight->originAirport->iata_code }}</strong>
    <span style="color: #3490dc; font-size: 1.5em; margin: 0 10px;">✈️</span>
    <strong style="font-size: 1.2em;">{{ $booking->flight->destinationAirport->iata_code }}</strong>
</div>

| Reference | Flight No. | Date |
| :--- | :--- | :--- |
| `{{ $booking->booking_reference }}` | **{{ $booking->flight->flight_number }}** | {{ \Carbon\Carbon::parse($booking->flight->departure_time)->format('M d, Y') }} |

<hr style="border: 0; border-top: 1px solid #eee; margin: 10px 0;">

**Seat Class:** {{ ucfirst($booking->seat_class) }}
**Status:** <span style="color: #38c172; font-weight: bold;">Confirmed ✅</span>
@endcomponent

### Quick Checklist for Your Trip:
* **Check-in:** Opens 24 hours before departure.
* **Documents:** Please bring a valid ID and your digital boarding pass.
* **Arrival:** Be at the airport at least 3 hours before your flight.

@component('mail::button', ['url' => config('app.url') . '/bookings/' . $booking->id, 'color' => 'success'])
View Booking Details
@endcomponent

If you need to make any changes, you can manage your booking through our app or reply to this email.

Safe travels,
**The FlyMate Team** ✈️
@endcomponent
