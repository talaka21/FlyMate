<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->colors([
                'primary' => Color::Sky,
                'gray' => Color::Slate,
                'danger' => Color::Rose,
                'info' => Color::Blue,
                'success' => Color::Emerald,
                'warning' => Color::Orange,
            ])
            ->brandName('✈ FlyMate')

            /* 🌐 زر تبديل اللغة السريع والتلقائي بتصميم الكبسولة الجديد */
            ->renderHook(
                \Filament\View\PanelsRenderHook::USER_MENU_BEFORE,
                fn() => new \Illuminate\Support\HtmlString('
        <a href="/admin/lang?locale=' . (app()->getLocale() === "en" ? "ar" : "en") . '"
           onmouseover="this.style.background=\'linear-gradient(135deg, #3b82f6, #2563eb)\'; this.style.color=\'white\'; this.style.borderColor=\'#2563eb\'; this.style.boxShadow=\'0 4px 12px rgba(59, 130, 246, 0.3)\';"
           onmouseout="this.style.background=\'linear-gradient(135deg, #f3f4f6, #e5e7eb)\'; this.style.color=\'#374151\'; this.style.borderColor=\'#d1d5db\'; this.style.boxShadow=\'0 1px 3px rgba(0, 0, 0, 0.05)\';"
           style="display: inline-flex; align-items: center; gap: 6px; padding: 4px 14px;
                  background: linear-gradient(135deg, #f3f4f6, #e5e7eb); color: #374151;
                  border: 1px solid #d1d5db; border-radius: 20px; text-decoration: none;
                  font-size: 12px; font-weight: 700; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
                  transition: all 0.2s ease-in-out; margin: 0 8px; cursor: pointer;">
            🌐 ' . (app()->getLocale() === "en" ? "English" : "العربية") . '
        </a>
    '),
            )

            ->favicon(asset('favicon.ico'))
            ->darkMode(true)
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                 \App\Filament\Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                \App\Filament\Widgets\StatsOverview::class,
                \App\Filament\Widgets\FlightsToday::class,
            ])
            ->middleware([
                \Illuminate\Cookie\Middleware\EncryptCookies::class,
                \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
                \Illuminate\Session\Middleware\StartSession::class, // 1. الجلسة تفتح هنا
                \App\Http\Middleware\SetLocale::class,              // 2. 👈 انقليه إلى هنا ليقرأ اللغة من الجلسة بنجاح!
                \Filament\Http\Middleware\AuthenticateSession::class,
                \Illuminate\View\Middleware\ShareErrorsFromSession::class,
                \Illuminate\Foundation\Http\Middleware\VerifyCsrfToken::class,
                \Illuminate\Routing\Middleware\SubstituteBindings::class,
                \Filament\Http\Middleware\DisableBladeIconComponents::class,
                \Filament\Http\Middleware\DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
