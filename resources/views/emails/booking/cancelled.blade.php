@component('mail::message')
# Booking Cancelled 🛑

Dear **{{ $booking->user->name }}**,

This email is to confirm that your booking has been **successfully cancelled** as requested. We're sorry to see you go!

@component('mail::panel')
### ✈️ Booking Summary
| Field | Details |
| :--- | :--- |
| **Reference** | `{{ $booking->booking_reference }}` |
| **Flight No.** | {{ $booking->flight->flight_number }} |
| **Route** | {{ $booking->flight->originAirport->iata_code }} → {{ $booking->flight->destinationAirport->iata_code }} |
| **Status** | <span style="color: #e3342f;">Cancelled</span> |
@endcomponent

### What happens next?
* **Refunds:** If applicable, your refund will be processed within 5-7 business days to your original payment method.
* **New Booking:** You can always book a new flight via our mobile app or website.

@component('mail::button', ['url' => config('app.url') . '/support', 'color' => 'error'])
Contact Support
@endcomponent

If this cancellation was not made by you, please secure your account and reach out to us immediately.

Safe travels,
**The FlyMate Team** ✈️
@endcomponent
