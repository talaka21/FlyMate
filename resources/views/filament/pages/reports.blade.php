<x-filament-panels::page>

<div style="display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 0px; padding: 0;">

    <form wire:change="$refresh" style="margin: 0; flex-grow: 1;">
        {{ $this->form }}
    </form>

    <div style="display: flex; gap: 8px; flex-shrink: 0;">
        <button wire:click="exportExcel"
                onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 12px rgba(34,197,94,0.4)'"
                onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(34,197,94,0.3)'"
                style="display: flex; align-items: center; gap: 8px;
                       padding: 9px 18px; background: linear-gradient(135deg, #16a34a, #22c55e);
                       color: white; border: none; border-radius: 7px; cursor: pointer;
                       font-size: 13px; font-weight: 700; box-shadow: 0 2px 6px rgba(34,197,94,0.3);
                       transition: all 0.2s ease;">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3M3 17V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
            </svg>
            Export Excel
        </button>

        <button wire:click="exportPdf"
                onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 12px rgba(239,68,68,0.4)'"
                onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(239,68,68,0.3)'"
                style="display: flex; align-items: center; gap: 8px;
                       padding: 9px 18px; background: linear-gradient(135deg, #dc2626, #ef4444);
                       color: white; border: none; border-radius: 7px; cursor: pointer;
                       font-size: 13px; font-weight: 700; box-shadow: 0 2px 6px rgba(239,68,68,0.3);
                       transition: all 0.2s ease;">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
            </svg>
            Export PDF
        </button>
    </div>
</div>



<style>
/* تصفير هوامش الـ Header الافتراضية للـ Filament لضمان البقاء في صفحة واحدة */
.fi-page-header, .fi-header { display: none !important; }
.fi-panels-page { gap: 0px !important; }

/* تنسيق الفلتر المندمج النحيف */
.fi-section {
    background: transparent !important;
    box-shadow: none !important;
    margin-bottom: 0px !important;
    border: none !important;
    padding: 0 !important;
}
.fi-section > .grid { display: flex !important; flex-direction: row !important; align-items: center !important; gap: 12px !important; }
.fi-section-header { padding: 0 !important; flex-shrink: 0 !important; }
.fi-section-header-heading { font-size: 13px !important; font-weight: 700 !important; color: #4b5563 !important; }
.fi-section-content { padding: 0 !important; }
.fi-section-content .grid, .fi-fo-grid { display: flex !important; flex-direction: row !important; align-items: center !important; gap: 12px !important; }
.fi-fo-field-wrp { display: flex !important; flex-direction: row !important; align-items: center !important; gap: 6px !important; margin: 0 !important; }
.fi-fo-field-wrp-label { margin-bottom: 0 !important; flex-shrink: 0 !important; }
.fi-fo-field-wrp-label span, .fi-fo-field-wrp-label label { font-size: 11px !important; font-weight: 600 !important; color: #6b7280 !important; }
.fi-input-wrp { width: 140px !important; height: 30px !important; min-height: 30px !important; border-radius: 6px !important; }
.fi-input-wrp input { font-size: 11px !important; }

/* التنسيق الجديد للكروت المقتبس بالكامل من صورة Claude */
.rpt-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 12px;
    margin: 2px 0 6px 0 !important;
}
.rpt-card {
    background: white;
    border: 1.5px solid var(--accent); /* إطار كامل ملون يحيط بالكرت */
    border-radius: 8px;
    padding: 12px 14px;
    box-shadow: 0 1px 2px rgba(0,0,0,0.02);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.rpt-label {
    font-size: 12px;
    font-weight: 600;
    color: #374151; /* لون عنواين غامق وأنيق */
    margin: 0 0 4px 0;
    display: flex;
    align-items: center;
    gap: 6px; /* مسافة بين الأيقونة والنص */
}
.rpt-label svg {
    color: #6b7280; /* لون الأيقونات الافتراضي النحيف */
    flex-shrink: 0;
}
.rpt-value {
    font-size: 26px;
    font-weight: 700;
    color: var(--accent); /* لون الرقم يطابق الإطار تماماً */
    margin: 0;
    line-height: 1.1;
}
.rpt-sub {
    font-size: 11px;
    color: #6b7280;
    margin: 2px 0 0 0;
}

/* تنسيق الفواصل والعناوين الجانبية */
.divider { height: 0.5px; background: #e5e7eb; margin: 2px 0 !important; }
.section-title {
    font-size: 11px;
    font-weight: 700;
    color: #9ca3af;
    text-transform: uppercase;
    letter-spacing: .05em;
    margin: 2px 0 4px 0 !important;
}
</style>

<div class="divider"></div>
<p class="section-title">Booking overview</p>
<div class="rpt-grid">
  <div class="rpt-card" style="--accent:#10B981">
    <p class="rpt-label">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
      Total bookings
    </p>
    <p class="rpt-value">{{ $stats['total_bookings'] }}</p>
    <p class="rpt-sub">All time</p>
  </div>

  <div class="rpt-card" style="--accent:#3B82F6">
    <p class="rpt-label">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 14 14"></polyline></svg>
      Confirmed
    </p>
    <p class="rpt-value">{{ $stats['confirmed'] }}</p>
    <p class="rpt-sub">Active bookings</p>
  </div>

  <div class="rpt-card" style="--accent:#EF4444">
    <p class="rpt-label">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
      Cancelled
    </p>
    <p class="rpt-value">{{ $stats['cancelled'] }}</p>
    <p class="rpt-sub">Refunded or voided</p>
  </div>

  <div class="rpt-card" style="--accent:#F59E0B">
    <p class="rpt-label">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
      Pending
    </p>
    <p class="rpt-value">{{ $stats['pending'] }}</p>
    <p class="rpt-sub">Awaiting confirmation</p>
  </div>
</div>

<div class="divider"></div>
<p class="section-title">Financial & operations</p>
<div class="rpt-grid">
  <div class="rpt-card" style="--accent:#10B981">
    <p class="rpt-label">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"></rect><line x1="12" y1="10" x2="12" y2="14"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
      Total revenue
    </p>
    <p class="rpt-value">${{ number_format($stats['total_revenue'], 2) }}</p>
    <p class="rpt-sub">USD collected</p>
  </div>

  <div class="rpt-card" style="--accent:#6366F1">
    <p class="rpt-label">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
      Total passengers
    </p>
    <p class="rpt-value">{{ $stats['total_passengers'] }}</p>
    <p class="rpt-sub">Registered travellers</p>
  </div>

  <div class="rpt-card" style="--accent:#3B82F6">
    <p class="rpt-label">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"></path></svg>
      Total flights
    </p>
    <p class="rpt-value">{{ number_format($stats['total_flights']) }}</p>
    <p class="rpt-sub">Scheduled routes</p>
  </div>

  <div class="rpt-card" style="--accent:#EF4444">
    <p class="rpt-label">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
      Cancelled flights
    </p>
    <p class="rpt-value">{{ $stats['cancelled_flights'] }}</p>
    <p class="rpt-sub" style="color: #EF4444; font-weight: 600;">
      @if($stats['total_flights'] > 0)
        {{ number_format($stats['cancelled_flights'] / $stats['total_flights'] * 100, 1) }}% cancellation rate
      @endif
    </p>
  </div>
</div>

</x-filament-panels::page>


