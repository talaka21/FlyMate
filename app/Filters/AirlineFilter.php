<?php

namespace App\Filters;
use Illuminate\Database\Eloquent\Builder;
class AirlineFilter
{
    /**
     * Create a new class instance.
     */
     protected Builder $query;
    protected array $filters;

    public function __construct(Builder $query, array $filters)
    {
        $this->query = $query;
        $this->filters = $filters;
    }

    public function apply(): Builder
    {
        foreach ($this->filters as $filter => $value) {
            if (method_exists($this, $filter) && !empty($value)) {
                $this->$filter($value);
            }
        }
        return $this->query;
    }

    // فلتر الـ rating الأدنى
    protected function min_rating($value): void
    {
        $this->query->where('rating', '>=', $value);
    }

    // فلتر الـ baggage الأدنى
    protected function min_baggage($value): void
    {
        $this->query->where('baggage_kg', '>=', $value);
    }

    // فلتر الـ destination (عن طريق جدول الـ flights)
    protected function destination($value): void
    {
        $this->query->whereHas('flights', function ($q) use ($value) {
            $q->where('destination_city', 'like', "%{$value}%")
              ->orWhere('destination_iata', $value);
        });
    }

    // فلتر الـ origin
    protected function origin($value): void
    {
        $this->query->whereHas('flights', function ($q) use ($value) {
            $q->where('origin_iata', $value);
        });
    }

    // فلتر الـ Wi-Fi
    protected function has_wifi($value): void
    {
        if ($value) $this->query->where('has_wifi', true);
    }

    // فلتر الـ Lounge
    protected function has_lounge($value): void
    {
        if ($value) $this->query->where('has_lounge', true);
    }

    // فلتر الـ Meals
    protected function has_meals($value): void
    {
        if ($value) $this->query->where('has_meals', true);
    }

    // فلتر السعر (عن طريق الـ flights)
    protected function max_price($value): void
    {
        $this->query->whereHas('flights', function ($q) use ($value) {
            $q->where('price', '<=', $value);
        });
    }

    // الترتيب
    protected function sort_by($value): void
    {
        match($value) {
            'rating'      => $this->query->orderByDesc('rating'),
            'baggage'     => $this->query->orderByDesc('baggage_kg'),
            'destinations'=> $this->query->orderByDesc('destinations_count'),
            default       => $this->query->orderBy('name'),
        };
    }
}
