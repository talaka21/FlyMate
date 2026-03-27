<x-filament-panels::page>
    <form wire:change="$refresh">
        {{ $this->form }}
    </form>

    @php $stats = $this->getStats() @endphp

    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin: 20px 0;">
        <div style="background: #f0fdf4; padding: 20px; border-radius: 12px; border-left: 4px solid #22c55e;">
            <div style="font-size: 13px; color: #666;">Total Bookings</div>
            <div style="font-size: 28px; font-weight: bold;">{{ $stats['total_bookings'] }}</div>
        </div>
        <div style="background: #eff6ff; padding: 20px; border-radius: 12px; border-left: 4px solid #3b82f6;">
            <div style="font-size: 13px; color: #666;">Confirmed</div>
            <div style="font-size: 28px; font-weight: bold; color: #3b82f6;">{{ $stats['confirmed'] }}</div>
        </div>
        <div style="background: #fef2f2; padding: 20px; border-radius: 12px; border-left: 4px solid #ef4444;">
            <div style="font-size: 13px; color: #666;">Cancelled</div>
            <div style="font-size: 28px; font-weight: bold; color: #ef4444;">{{ $stats['cancelled'] }}</div>
        </div>
        <div style="background: #fffbeb; padding: 20px; border-radius: 12px; border-left: 4px solid #f59e0b;">
            <div style="font-size: 13px; color: #666;">Pending</div>
            <div style="font-size: 28px; font-weight: bold; color: #f59e0b;">{{ $stats['pending'] }}</div>
        </div>
        <div style="background: #f0fdf4; padding: 20px; border-radius: 12px; border-left: 4px solid #22c55e;">
            <div style="font-size: 13px; color: #666;">Total Revenue</div>
            <div style="font-size: 28px; font-weight: bold; color: #22c55e;">${{ number_format($stats['total_revenue'], 2) }}</div>
        </div>
        <div style="background: #f5f3ff; padding: 20px; border-radius: 12px; border-left: 4px solid #8b5cf6;">
            <div style="font-size: 13px; color: #666;">Total Passengers</div>
            <div style="font-size: 28px; font-weight: bold; color: #8b5cf6;">{{ $stats['total_passengers'] }}</div>
        </div>
        <div style="background: #eff6ff; padding: 20px; border-radius: 12px; border-left: 4px solid #3b82f6;">
            <div style="font-size: 13px; color: #666;">Total Flights</div>
            <div style="font-size: 28px; font-weight: bold; color: #3b82f6;">{{ $stats['total_flights'] }}</div>
        </div>
        <div style="background: #fef2f2; padding: 20px; border-radius: 12px; border-left: 4px solid #ef4444;">
            <div style="font-size: 13px; color: #666;">Cancelled Flights</div>
            <div style="font-size: 28px; font-weight: bold; color: #ef4444;">{{ $stats['cancelled_flights'] }}</div>
        </div>
    </div>

    <div style="display: flex; gap: 12px; margin-top: 20px;">
        <button wire:click="exportExcel"
                style="padding: 10px 20px; background: #22c55e; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 14px;">
            📊 Export Excel
        </button>
        <button wire:click="exportPdf"
                style="padding: 10px 20px; background: #ef4444; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 14px;">
            📄 Export PDF
        </button>
    </div>
</x-filament-panels::page>
