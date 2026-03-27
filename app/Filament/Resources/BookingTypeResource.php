<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BookingTypeResource\Pages;
use App\Models\BookingType;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class BookingTypeResource extends Resource
{
    protected static ?string $model = BookingType::class;
    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';
    protected static ?string $navigationGroup = 'Flight Management';

    public static function canViewAny(): bool
    {
        return in_array(auth()->user()->role, ['admin', 'manager']);
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('name')->required(),
            Forms\Components\Select::make('type')
                ->options([
                    'one_way'    => 'One Way',
                    'round_trip' => 'Round Trip',
                    'multi_city' => 'Multi City',
                ])->required(),
            Forms\Components\TextInput::make('cancellation_fee_72h')
                ->numeric()->default(0)->label('Cancellation Fee +72h (%)'),
            Forms\Components\TextInput::make('cancellation_fee_24h')
                ->numeric()->default(20)->label('Cancellation Fee 24h (%)'),
            Forms\Components\TextInput::make('cancellation_fee_less_24h')
                ->numeric()->default(50)->label('Cancellation Fee <24h (%)'),
            Forms\Components\TextInput::make('baggage_allowance')
                ->nullable()->label('Baggage Allowance (kg)'),
            Forms\Components\Toggle::make('is_active')
                ->default(true)->label('Active'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable(),
                Tables\Columns\BadgeColumn::make('type')
                    ->colors([
                        'info'    => 'one_way',
                        'success' => 'round_trip',
                        'warning' => 'multi_city',
                    ]),
                Tables\Columns\TextColumn::make('baggage_allowance')->label('Baggage (kg)'),
                Tables\Columns\IconColumn::make('is_active')->boolean(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListBookingTypes::route('/'),
            'create' => Pages\CreateBookingType::route('/create'),
            'edit'   => Pages\EditBookingType::route('/{record}/edit'),
        ];
    }
}
