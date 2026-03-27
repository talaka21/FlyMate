<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FlightPriceResource\Pages;
use App\Models\FlightPrice;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class FlightPriceResource extends Resource
{
    protected static ?string $model = FlightPrice::class;
    protected static ?string $navigationIcon = 'heroicon-o-banknotes';
    protected static ?string $navigationGroup = 'Flight Management';

    public static function canViewAny(): bool
    {
        return in_array(auth()->user()->role, ['admin', 'manager']);
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Select::make('flight_id')
                ->relationship('flight', 'flight_number')->required(),
            Forms\Components\Select::make('class')
                ->options([
                    'economy'     => 'Economy',
                    'business'    => 'Business',
                    'first_class' => 'First Class',
                ])->required(),
            Forms\Components\TextInput::make('base_price')
                ->numeric()->required()->prefix('$'),
            Forms\Components\TextInput::make('min_price')
                ->numeric()->nullable()->prefix('$'),
            Forms\Components\TextInput::make('max_price')
                ->numeric()->nullable()->prefix('$'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('flight.flight_number')->label('Flight'),
                Tables\Columns\BadgeColumn::make('class')
                    ->colors([
                        'success' => 'economy',
                        'warning' => 'business',
                        'danger'  => 'first_class',
                    ]),
                Tables\Columns\TextColumn::make('base_price')->money('USD')->sortable(),
                Tables\Columns\TextColumn::make('min_price')->money('USD'),
                Tables\Columns\TextColumn::make('max_price')->money('USD'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListFlightPrices::route('/'),
            'create' => Pages\CreateFlightPrice::route('/create'),
            'edit'   => Pages\EditFlightPrice::route('/{record}/edit'),
        ];
    }
}
