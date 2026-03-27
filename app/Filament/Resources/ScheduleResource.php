<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ScheduleResource\Pages;
use App\Models\Schedule;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ScheduleResource extends Resource
{
    protected static ?string $model = Schedule::class;
    protected static ?string $navigationIcon = 'heroicon-o-calendar';
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
            Forms\Components\Select::make('origin_airport_id')
                ->relationship('originAirport', 'name')->required(),
            Forms\Components\Select::make('destination_airport_id')
                ->relationship('destinationAirport', 'name')->required(),
            Forms\Components\TimePicker::make('departure_time')->required(),
            Forms\Components\TimePicker::make('arrival_time')->required(),
            Forms\Components\CheckboxList::make('days_of_week')
                ->options([
                    '1' => 'Monday',
                    '2' => 'Tuesday',
                    '3' => 'Wednesday',
                    '4' => 'Thursday',
                    '5' => 'Friday',
                    '6' => 'Saturday',
                    '7' => 'Sunday',
                ])->required(),
            Forms\Components\DatePicker::make('valid_from')->required(),
            Forms\Components\DatePicker::make('valid_until')->required(),
            Forms\Components\Select::make('status')
                ->options([
                    'active'    => 'Active',
                    'cancelled' => 'Cancelled',
                    'postponed' => 'Postponed',
                ])->default('active')->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('flight.flight_number')->label('Flight'),
                Tables\Columns\TextColumn::make('originAirport.iata_code')->label('From'),
                Tables\Columns\TextColumn::make('destinationAirport.iata_code')->label('To'),
                Tables\Columns\TextColumn::make('departure_time'),
                Tables\Columns\TextColumn::make('arrival_time'),
                Tables\Columns\TextColumn::make('valid_from')->date(),
                Tables\Columns\TextColumn::make('valid_until')->date(),
                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'success' => 'active',
                        'danger'  => 'cancelled',
                        'warning' => 'postponed',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListSchedules::route('/'),
            'create' => Pages\CreateSchedule::route('/create'),
            'edit'   => Pages\EditSchedule::route('/{record}/edit'),
        ];
    }
}
