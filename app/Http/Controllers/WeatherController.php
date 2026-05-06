<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\WeatherService;
class WeatherController extends Controller
{
    public function __construct(protected WeatherService $weather) {}

    public function show(string $city)
    {
        return response()->json(
            $this->weather->getWeather($city)
        );
    }
}
