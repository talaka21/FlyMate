<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Destination;
use App\Traits\ApiResponse;

class DestinationController extends Controller
{
    use ApiResponse;

    // كل الوجهات الشعبية
    public function index()
    {
        $destinations = Destination::where('is_popular', true)
            ->with('neighborhoods.spots')
            ->get();

        return $this->success($destinations);
    }

    // تفاصيل وجهة واحدة
    public function show($id)
    {
        $destination = Destination::with('neighborhoods.spots')
            ->findOrFail($id);

        return $this->success($destination);
    }
}
