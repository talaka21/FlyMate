<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BookingResource\Pages;
use App\Models\Booking;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Actions\Action;

class BookingResource extends Resource
{
    protected static ?string $model = Booking::class;
    protected static ?string $navigationIcon = 'heroicon-o-ticket';

    public static function canViewAny(): bool
    {
        return auth()->user()->role === 'admin';
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('reference')->required()->maxLength(255),
            Forms\Components\Select::make('user_id')
                ->relationship('user', 'name')->required()->label('Passenger'),
            Forms\Components\Select::make('flight_id')
                ->relationship('flight', 'flight_number')->required()->label('Flight'),
            Forms\Components\Select::make('booking_type_id')
                ->relationship('bookingType', 'name')->required()->label('Booking Type'),
            Forms\Components\Select::make('seat_class')
                ->options([
                    'economy'     => 'Economy',
                    'business'    => 'Business',
                    'first_class' => 'First Class',
                ])->required(),
            Forms\Components\Select::make('status')
                ->options([
                    'pending'   => 'Pending',
                    'confirmed' => 'Confirmed',
                    'cancelled' => 'Cancelled',
                    'completed' => 'Completed',
                ])->required(),
            Forms\Components\TextInput::make('total_price')->numeric()->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('reference')->searchable(),
                Tables\Columns\TextColumn::make('user.name')->label('Passenger')->searchable(),
                Tables\Columns\TextColumn::make('flight.flight_number')->label('Flight'),
                Tables\Columns\TextColumn::make('bookingType.name')->label('Type'),
                Tables\Columns\BadgeColumn::make('seat_class')
                    ->colors([
                        'success' => 'economy',
                        'warning' => 'business',
                        'danger'  => 'first_class',
                    ]),
                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'confirmed',
                        'danger'  => 'cancelled',
                        'info'    => 'completed',
                    ]),
                Tables\Columns\TextColumn::make('total_price')->money('USD')->sortable(),
                Tables\Columns\TextColumn::make('created_at')->dateTime()->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->headerActions([
                Action::make('export')
                    ->label('Export Excel')
                    ->icon('heroicon-o-arrow-down-tray')
                    ->color('success')
                    ->action(fn() => (new \App\Exports\BookingsExport)->download()),
            ])
            ->filters([])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListBookings::route('/'),
            'create' => Pages\CreateBooking::route('/create'),
            'edit'   => Pages\EditBooking::route('/{record}/edit'),
        ];
    }
}
