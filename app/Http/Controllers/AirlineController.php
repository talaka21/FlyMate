<?php

namespace App\Http\Controllers;

use App\Filters\AirlineFilter;
use App\Models\Airline;
use Illuminate\Http\Request;

class AirlineController extends Controller
{
    public function index(Request $request)
    {
        $filters = $request->only([
            'min_rating',
            'min_baggage',
            'destination',
            'origin',
            'has_wifi',
            'has_lounge',
            'has_meals',
            'max_price',
            'sort_by',
        ]);

        $query = Airline::query()->where('is_active', true);

        $airlines = (new AirlineFilter($query, $filters))
            ->apply()
            ->with('flights') // إذا بدك تجيب الـ flights معها
            ->paginate(10);

        return response()->json($airlines);
    }
    // AirlineController - show
public function show(Airline $airline)
{
    return response()->json([
        'id'          => $airline->id,
        'name'        => $airline->name,
        'hub_city'    => $airline->hub_city,
        'tagline'     => $airline->tagline,
        'logo'        => $airline->logo,
        'stats' => [
            'destinations' => $airline->destinations_count,
            'baggage_kg'   => $airline->baggage_kg,
            'rating'       => $airline->rating,
        ],
        'features' => [
            'wifi'          => $airline->has_wifi,
            'lounge'        => $airline->has_lounge,
            'meals'         => $airline->has_meals,
            'entertainment' => $airline->has_entertainment,
        ],
        'flights' => $airline->flights->map(fn($f) => [
            'from'      => $f->originAirport->city,
            'to'        => $f->destinationAirport->city,
            'price'     => $f->prices->min('amount'),
            'duration'  => $f->duration_label,
            'frequency' => $f->frequency,
        ]),
    ]);
}
}
