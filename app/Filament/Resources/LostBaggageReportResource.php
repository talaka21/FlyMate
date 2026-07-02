<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LostBaggageReportResource\Pages;
use App\Models\LostBaggageReport;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class LostBaggageReportResource extends Resource
{
    protected static ?string $model = LostBaggageReport::class;
    protected static ?string $navigationIcon = 'heroicon-o-archive-box-x-mark';
    protected static ?string $navigationLabel = 'Lost Baggage';
    protected static ?string $navigationGroup = 'System';
    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Flight Info')->schema([
                Forms\Components\TextInput::make('reference_number')
                    ->required()->maxLength(255)->disabled(),
                Forms\Components\TextInput::make('flight_number')
                    ->required()->maxLength(255),
                Forms\Components\TextInput::make('departure_city')
                    ->required()->maxLength(255),
                Forms\Components\TextInput::make('arrival_city')
                    ->required()->maxLength(255),
                Forms\Components\DatePicker::make('arrival_date')
                    ->required(),
                Forms\Components\TextInput::make('airport_code')
                    ->required()->maxLength(255),
            ])->columns(2),

            Forms\Components\Section::make('Baggage Info')->schema([
                Forms\Components\Select::make('baggage_type')
                    ->options([
                        'suitcase'  => 'Suitcase',
                        'backpack'  => 'Backpack',
                        'hand_bag'  => 'Hand Bag',
                        'other'     => 'Other',
                    ])->required(),
                Forms\Components\Select::make('baggage_size')
                    ->options([
                        'small'  => 'Small',
                        'medium' => 'Medium',
                        'large'  => 'Large',
                    ])->required(),
                Forms\Components\TextInput::make('baggage_color')
                    ->required()->maxLength(255),
                Forms\Components\TextInput::make('distinctive_marks')
                    ->maxLength(255),
                Forms\Components\Textarea::make('description')
                    ->required()->columnSpanFull(),
            ])->columns(2),

            Forms\Components\Section::make('Contact Info')->schema([
                Forms\Components\TextInput::make('contact_phone')
                    ->tel()->required()->maxLength(255),
                Forms\Components\TextInput::make('contact_email')
                    ->email()->required()->maxLength(255),
                Forms\Components\TextInput::make('delivery_address')
                    ->maxLength(255)->columnSpanFull(),
            ])->columns(2),

            Forms\Components\Section::make('Admin')->schema([
                Forms\Components\Select::make('status')
                    ->options([
                        'pending_review' => 'Pending Review',
                        'sent_to_airport' => 'Sent to Airport',
                        'searching'      => 'Searching',
                        'found'          => 'Found',
                        'in_delivery'    => 'In Delivery',
                        'delivered'      => 'Delivered',
                        'closed'         => 'Closed',
                    ])->required(),
                Forms\Components\Select::make('assigned_to')
                    ->options(User::whereIn('role', ['admin', 'manager'])->pluck('name', 'id'))
                    ->searchable()->nullable(),
                Forms\Components\Textarea::make('admin_notes')
                    ->columnSpanFull(),
            ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('reference_number')
                    ->searchable()->sortable(),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Passenger')->searchable(),
                Tables\Columns\TextColumn::make('flight_number')
                    ->searchable(),
                Tables\Columns\TextColumn::make('departure_city')
                    ->searchable(),
                Tables\Columns\TextColumn::make('arrival_city')
                    ->searchable(),
                Tables\Columns\TextColumn::make('arrival_date')
                    ->date()->sortable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'gray'    => 'pending_review',
                        'warning' => ['sent_to_airport', 'searching'],
                        'success' => ['found', 'in_delivery', 'delivered'],
                        'danger'  => 'closed',
                    ]),
                Tables\Columns\TextColumn::make('assignedTo.name')
                    ->label('Assigned To')->default('—'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending_review'  => 'Pending Review',
                        'sent_to_airport' => 'Sent to Airport',
                        'searching'       => 'Searching',
                        'found'           => 'Found',
                        'in_delivery'     => 'In Delivery',
                        'delivered'       => 'Delivered',
                        'closed'          => 'Closed',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListLostBaggageReports::route('/'),
            'create' => Pages\CreateLostBaggageReport::route('/create'),
            'edit'   => Pages\EditLostBaggageReport::route('/{record}/edit'),
        ];
    }
}
