<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        h1 { color: #0ea5e9; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #0ea5e9; color: white; padding: 10px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #eee; }
    </style>
</head>
<body>
    <h1>✈ FlyMate - System Report</h1>
    <p style="text-align:center; color:#666;">Generated: {{ now()->format('Y-m-d H:i') }}</p>
    <table>
        <tr><th>Metric</th><th>Value</th></tr>
        <tr><td>Total Bookings</td><td>{{ $stats['total_bookings'] }}</td></tr>
        <tr><td>Confirmed Bookings</td><td>{{ $stats['confirmed'] }}</td></tr>
        <tr><td>Cancelled Bookings</td><td>{{ $stats['cancelled'] }}</td></tr>
        <tr><td>Pending Bookings</td><td>{{ $stats['pending'] }}</td></tr>
        <tr><td>Total Revenue</td><td>${{ number_format($stats['total_revenue'], 2) }}</td></tr>
        <tr><td>Total Passengers</td><td>{{ $stats['total_passengers'] }}</td></tr>
        <tr><td>Total Flights</td><td>{{ $stats['total_flights'] }}</td></tr>
        <tr><td>Cancelled Flights</td><td>{{ $stats['cancelled_flights'] }}</td></tr>
    </table>
</body>
</html>
