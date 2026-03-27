@component('mail::message')
# Your Flight Has Been Updated 🔄

Hi **{{ $booking->user->name }}**,

Your booking was successfully rescheduled. Please review your **updated flight itinerary** below to ensure everything is correct for your upcoming journey.

@component('mail::panel')
### ✈️ New Flight Details
<div style="font-size: 1.1em; margin-bottom: 10px;">
    <strong>{{ $booking->flight->originAirport->iata_code }}</strong>
    <span style="color: #3490dc;"> ➔ </span>
    <strong>{{ $booking->flight->destinationAirport->iata_code }}</strong>
</div>

| Reference | Flight No. | New Departure Date |
| :--- | :--- | :--- |
| `{{ $booking->booking_reference }}` | **{{ $booking->flight->flight_number }}** | {{ \Carbon\Carbon::parse($booking->flight->departure_time)->format('D, M d, Y') }} |

<hr style="border: 0; border-top: 1px solid #eee; margin: 10px 0;">

**Departure Time:** {{ \Carbon\Carbon::parse($booking->flight->departure_time)->format('h:i A') }}
**Status:** <span style="color: #3490dc; font-weight: bold;">Updated & Confirmed 🔄</span>
@endcomponent

### 💡 Important Note:
Your previous tickets are now **invalid**. Please use your updated booking reference for check-in and during your time at the airport.

@component('mail::button', ['url' => config('app.url') . '/bookings/' . $booking->id, 'color' => 'primary'])
View Updated Itinerary
@endcomponent

If you did not request this change, please contact our support team immediately.

Safe travels,
**The FlyMate Team** ✈️
@endcomponent
