<?php

namespace App\Observers;

use App\Models\User;
use App\Models\AuditLog;
use Illuminate\Support\Facades\Auth;
class UserObserver
{
    /**
     * Handle the User "created" event.
     */
    public function created(User $user): void
    {
        AuditLog::create([
            'user_id'    => Auth::id() ?? $user->id,
            'action'     => 'created',
            'model'      => 'User',
            'model_id'   => $user->id,
            'old_values' => null,
            'new_values' => $user->toArray(),
        ]);
    }

    /**
     * Handle the User "updated" event.
     */
    public function updated(User $user): void
    {
 AuditLog::create([
            'user_id'    => Auth::id() ?? $user->id,
            'action'     => 'updated',
            'model'      => 'User',
            'model_id'   => $user->id,
            'old_values' => $user->getOriginal(),
            'new_values' => $user->getChanges(),
        ]);
    }

    /**
     * Handle the User "deleted" event.
     */
    public function deleted(User $user): void
    {
      AuditLog::create([
            'user_id'    => Auth::id() ?? $user->id,
            'action'     => 'deleted',
            'model'      => 'User',
            'model_id'   => $user->id,
            'old_values' => $user->toArray(),
            'new_values' => null,
        ]);
    }

    /**
     * Handle the User "restored" event.
     */
    public function restored(User $user): void
    {
        //
    }

    /**
     * Handle the User "force deleted" event.
     */
    public function forceDeleted(User $user): void
    {
        //
    }
}
