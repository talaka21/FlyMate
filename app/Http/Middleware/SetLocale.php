<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SetLocale
{
    public function handle(Request $request, Closure $next): Response
    {
        // للـ API: اقرأ من Accept-Language header
        // للويب: ارجع للـ session أو default
        $locale = $request->header('Accept-Language')
            ?? session('locale', config('app.locale'));

        // تأكد اللغة مدعومة
        if (in_array($locale, ['en', 'ar'])) {
            app()->setLocale($locale);
        } else {
            app()->setLocale(config('app.locale'));
        }

        return $next($request);
    }
}
