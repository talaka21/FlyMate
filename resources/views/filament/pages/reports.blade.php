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
<div style="display: flex; gap: 12px; margin-top: 24px;">
    <button wire:click="exportExcel"
            onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 8px 20px rgba(34,197,94,0.5)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(34,197,94,0.4)'"
            style="display: flex; align-items: center; gap: 8px;
                   padding: 12px 24px; background: linear-gradient(135deg, #16a34a, #22c55e);
                   color: white; border: none; border-radius: 10px; cursor: pointer;
                   font-size: 14px; font-weight: 600; box-shadow: 0 4px 12px rgba(34,197,94,0.4);
                   transition: all 0.3s ease;">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3M3 17V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
        </svg>
        Export Excel
    </button>

    <button wire:click="exportPdf"
            onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 8px 20px rgba(239,68,68,0.5)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(239,68,68,0.4)'"
            style="display: flex; align-items: center; gap: 8px;
                   padding: 12px 24px; background: linear-gradient(135deg, #dc2626, #ef4444);
                   color: white; border: none; border-radius: 10px; cursor: pointer;
                   font-size: 14px; font-weight: 600; box-shadow: 0 4px 12px rgba(239,68,68,0.4);
                   transition: all 0.3s ease;">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
        </svg>
        Export PDF
    </button>
</div>
</x-filament-panels::page>
