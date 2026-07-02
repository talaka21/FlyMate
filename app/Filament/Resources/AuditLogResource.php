<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AuditLogResource\Pages;
use App\Models\AuditLog;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class AuditLogResource extends Resource
{
    protected static ?string $model = AuditLog::class;

    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';
    protected static ?string $navigationGroup = 'System';

    public static function canViewAny(): bool
    {
        return auth()->user()->role === 'admin';
    }

    public static function form(Form $form): Form
    {
        return $form->schema([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('User')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('action')
                    ->badge()
                    ->searchable()
                    ->color(fn(string $state): string => match ($state) {
                        'Login'                => 'info',    // أزرق سماوي
                        'Create Flight'        => 'success', // أخضر
                        'Update Flight'        => 'warning', // برتقالي
                        'Update Status Toggle' => 'primary', // لون متناسق مع ثيم النظام
                        'Cancel Booking'       => 'danger',  // أحمر
                        default                => 'gray',    // رمادي
                    }),

                Tables\Columns\TextColumn::make('model')
                    ->searchable(),

                Tables\Columns\TextColumn::make('model_id')
                    ->label('Record ID'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Time'),
            ])
            ->defaultSort('created_at', 'desc')

            ->filters([
                Tables\Filters\SelectFilter::make('action')
                    ->options([
                        'Login'                => 'Login',
                        'Create Flight'        => 'Create Flight',
                        'Update Flight'        => 'Update Flight',
                        'Update Status Toggle' => 'Update Status Toggle',
                        'Cancel Booking'       => 'Cancel Booking',
                    ]),
            ])

            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('View')
                    ->icon('heroicon-m-eye')
                    ->color('primary') // تم تعديله إلى primary ليطابق درجة أزرق القائمة الجانبية تماماً
                    ->link(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAuditLogs::route('/'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function canDelete($record): bool
    {
        return false;
    }
}
