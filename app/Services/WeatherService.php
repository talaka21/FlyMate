<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class WeatherService
{
    public function getWeather(string $city): array
    {
        $response = Http::get('https://api.openweathermap.org/data/2.5/weather', [
            'q'     => $city,
            'appid' => config('services.openweather.key'),
            'units' => 'metric',
            'lang'  => 'en',
        ]);

        $data = $response->json();

        return [
            'city'        => $data['name'],
            'temp'        => $data['main']['temp'],
            'feels_like'  => $data['main']['feels_like'],
            'description' => $data['weather'][0]['description'],
            'icon'        => $data['weather'][0]['icon'],
            'humidity'    => $data['main']['humidity'],
            'wind'        => $data['wind']['speed'],
        ];
    }
}
