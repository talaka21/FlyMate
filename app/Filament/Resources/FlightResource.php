<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FlightResource\Pages;
use App\Filament\Resources\FlightResource\RelationManagers;
use App\Models\Flight;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class FlightResource extends Resource
{
    protected static ?string $model = Flight::class;

    protected static ?string $navigationIcon = 'heroicon-o-paper-airplane';
    protected static ?string $navigationGroup = 'Flight Management';

        public static function canViewAny(): bool
    {
    $user = auth()->user();
    return in_array($user->role, ['admin', 'manager']);
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('flight_number')->required()->unique(ignoreRecord: true),
            Forms\Components\Select::make('airline_id')
                ->relationship('airline', 'name')->required(),
            Forms\Components\Select::make('origin_airport_id')
                ->relationship('originAirport', 'name')->required(),
            Forms\Components\Select::make('destination_airport_id')
                ->relationship('destinationAirport', 'name')->required(),
            Forms\Components\DateTimePicker::make('departure_at')->required(),
            Forms\Components\DateTimePicker::make('arrival_at')->required(),
            Forms\Components\TextInput::make('aircraft_type'),
            Forms\Components\TextInput::make('total_seats')->numeric()->required(),
            Forms\Components\Select::make('status')
                ->options([
                    'on_time'   => 'On Time',
                    'delayed'   => 'Delayed',
                    'cancelled' => 'Cancelled',
                ])->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('flight_number')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('airline.name')->sortable(),
                Tables\Columns\TextColumn::make('originAirport.iata_code')->label('From'),
                Tables\Columns\TextColumn::make('destinationAirport.iata_code')->label('To'),
                Tables\Columns\TextColumn::make('departure_at')->dateTime()->sortable(),
                Tables\Columns\TextColumn::make('arrival_at')->dateTime()->sortable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'success' => 'on_time',
                        'warning' => 'delayed',
                        'danger'  => 'cancelled',
                    ]),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'on_time'   => 'On Time',
                        'delayed'   => 'Delayed',
                        'cancelled' => 'Cancelled',
                    ]),
                Tables\Filters\SelectFilter::make('airline')
                    ->relationship('airline', 'name'),
            ])
            ->actions([
                Tables\Actions\Action::make('cancel')
                    ->label('Cancel Flight')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (Flight $record) => $record->status !== 'cancelled')
                    ->action(fn (Flight $record) => $record->update(['status' => 'cancelled']))
                    ->requiresConfirmation(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListFlights::route('/'),
            'create' => Pages\CreateFlight::route('/create'),
            'edit'   => Pages\EditFlight::route('/{record}/edit'),
        ];
    }

}
