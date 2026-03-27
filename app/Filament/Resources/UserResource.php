<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Filament\Resources\UserResource\RelationManagers;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
    protected static ?string $navigationGroup = 'User Management';
    public static function canViewAny(): bool
    {
    return auth()->user()->role === 'admin';
    }

    public static function form(Form $form): Form
    {
       return $form->schema([
            Forms\Components\TextInput::make('name')->required(),
            Forms\Components\TextInput::make('email')->email()->required()->unique(ignoreRecord: true),
            Forms\Components\TextInput::make('password')->password()->required()->hiddenOn('edit'),
            Forms\Components\Select::make('role')
                ->options([
                    'admin'     => 'Admin',
                    'manager'   => 'Manager',
                    'passenger' => 'Passenger',
                ])->required(),
            Forms\Components\Select::make('status')
                ->options([
                    'active'  => 'Active',
                    'pending' => 'Pending',
                    'banned'  => 'Banned',
                ])->required(),
            Forms\Components\TextInput::make('employee_id')->nullable(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('email')->searchable(),
                Tables\Columns\BadgeColumn::make('role')
                    ->colors([
                        'danger'  => 'admin',
                        'warning' => 'manager',
                        'success' => 'passenger',
                    ]),
                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'success' => 'active',
                        'warning' => 'pending',
                        'danger'  => 'banned',
                    ]),
                Tables\Columns\TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('role')
                    ->options([
                        'admin'     => 'Admin',
                        'manager'   => 'Manager',
                        'passenger' => 'Passenger',
                    ]),
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'active'  => 'Active',
                        'pending' => 'Pending',
                        'banned'  => 'Banned',
                    ]),
            ])
            ->actions([
                // ③ Actions خاصة
                Tables\Actions\Action::make('approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->visible(fn (User $record) => $record->role === 'manager' && $record->status === 'pending')
                    ->action(fn (User $record) => $record->update(['status' => 'active']))
                    ->requiresConfirmation(),

                Tables\Actions\Action::make('ban')
                    ->label('Ban')
                    ->icon('heroicon-o-no-symbol')
                    ->color('danger')
                    ->visible(fn (User $record) => $record->status === 'active' && $record->role === 'passenger')
                    ->action(fn (User $record) => $record->update(['status' => 'banned']))
                    ->requiresConfirmation(),

                Tables\Actions\Action::make('unban')
                    ->label('Unban')
                    ->icon('heroicon-o-check-circle')
                    ->color('warning')
                    ->visible(fn (User $record) => $record->status === 'banned')
                    ->action(fn (User $record) => $record->update(['status' => 'active']))
                    ->requiresConfirmation(),

                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit'   => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
