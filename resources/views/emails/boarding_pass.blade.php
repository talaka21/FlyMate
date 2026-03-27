<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f9; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 20px auto; background: #ffffff; border-radius: 15px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #1a73e8, #0d47a1); color: white; padding: 30px; text-align: center; }
        .header h1 { margin: 0; font-size: 24px; letter-spacing: 2px; }
        .header p { margin: 5px 0 0; opacity: 0.9; }
        .content { padding: 30px; }
        .ticket-box { border: 2px dashed #e0e0e0; border-radius: 10px; padding: 20px; background-color: #fafafa; margin-bottom: 25px; }
        .flight-route { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .route-point { text-align: center; flex: 1; }
        .route-point h2 { margin: 0; color: #1a73e8; font-size: 28px; }
        .plane-icon { font-size: 24px; color: #ccc; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; border-top: 1px solid #eee; padding-top: 15px; margin-top: 15px; }
        .info-item { font-size: 14px; color: #666; }
        .info-item b { color: #333; display: block; font-size: 16px; }
        .qr-section { text-align: center; padding: 20px; background: #fdfdfd; border-top: 1px solid #eee; }
        .qr-code { width: 180px; height: 180px; margin-bottom: 10px; border: 5px solid #fff; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .footer { text-align: center; padding: 20px; font-size: 12px; color: #999; }
        .btn { display: inline-block; padding: 12px 25px; background-color: #1a73e8; color: white; text-decoration: none; border-radius: 25px; font-weight: bold; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>FlyMate</h1>
            <p>Your Boarding Pass is Ready!</p>
        </div>

        <div class="content">
            {{-- ✅ تم التصحيح: user->name بدل passenger_name --}}
            <p>Hi <b>{{ $booking->user?->name ?? 'Traveler' }}</b>,</p>
            <p>Get ready for takeoff! Your booking is confirmed and your digital ticket is attached below.</p>

            <div class="ticket-box">
                <div class="flight-route">
                    <div class="route-point">
                        {{-- ✅ تم التصحيح: flight->originAirport->code بدل from_code --}}
                        <h2>{{ $booking->flight?->originAirport?->code ?? 'N/A' }}</h2>
                        <small>{{ $booking->flight?->originAirport?->city ?? '' }}</small>
                    </div>
                    <div class="plane-icon">✈</div>
                    <div class="route-point">
                        {{-- ✅ تم التصحيح: flight->destinationAirport->code بدل to_code --}}
                        <h2>{{ $booking->flight?->destinationAirport?->code ?? 'N/A' }}</h2>
                        <small>{{ $booking->flight?->destinationAirport?->city ?? '' }}</small>
                    </div>
                </div>

                <div class="info-grid">
                    {{-- ✅ تم التصحيح: flight->flight_number بدل flight_number --}}
                    <div class="info-item">Flight Number <b>{{ $booking->flight?->flight_number ?? 'N/A' }}</b></div>
                    <div class="info-item">Date <b>{{ $booking->flight?->departure_at ? \Carbon\Carbon::parse($booking->flight->departure_at)->format('M d, Y') : now()->format('M d, Y') }}</b></div>
                    {{-- ✅ تم التصحيح: seat->seat_number بدل seat_number --}}
                    <div class="info-item">Seat <b>{{ $booking->seat?->seat_number ?? 'N/A' }}</b></div>
                    <div class="info-item">Class <b>{{ ucfirst($booking->seat_class) }}</b></div>
                </div>
            </div>

            <div style="text-align: center;">
                <a href="http://localhost:8000/bookings/{{ $booking->id }}" class="btn">View Booking Online</a>
            </div>
        </div>

        <div class="qr-section">
            <p><b>Scan at Gate</b></p>
            {{-- ✅ $qrCode يجي من BoardingPassMail مباشرة --}}
            <img src="{{ $qrCode }}" class="qr-code" alt="Boarding Pass QR">
            <p><small>Boarding Code: {{ $booking->boarding_code }}</small></p>
        </div>

        <div class="footer">
            &copy; 2026 FlyMate Airlines. All rights reserved.<br>
            Please be at the airport 3 hours before departure.
        </div>
    </div>
</body>
</html>
