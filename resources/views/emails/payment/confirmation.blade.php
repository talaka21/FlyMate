@component('mail::message')
# Payment Successful! 💳

Hi **{{ $booking->user->name }}**,

Thank you! We’ve successfully received your payment for your upcoming trip. Your booking is now fully secured.

@component('mail::panel')
<div style="text-align: center; margin-bottom: 15px;">
    <span style="color: #666; font-size: 0.9em; text-transform: uppercase;">Amount Paid</span><br>
    <strong style="font-size: 2.2em; color: #2d3748;">${{ number_format($booking->total_price, 2) }}</strong>
</div>

| Transaction Details | |
| :--- | :--- |
| **Booking Ref:** | `{{ $booking->booking_reference }}` |
| **Flight:** | {{ $booking->flight->flight_number }} |
| **Route:** | {{ $booking->flight->originAirport->iata_code }} → {{ $booking->flight->destinationAirport->iata_code }} |
| **Payment Status:** | <span style="color: #38c172; font-weight: bold;">Verified ✅</span> |
@endcomponent

### What’s next?
You can now download your **E-Ticket** and **Receipt** from your dashboard. We recommend keeping a digital copy on your phone during travel.

@component('mail::button', ['url' => config('app.url') . '/bookings/' . $booking->id, 'color' => 'success'])
Download Receipt
@endcomponent

If you have any questions regarding this transaction, please contact our billing department.

Happy travels,
**The FlyMate Team** ✈️
@endcomponent
