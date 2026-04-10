<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPasswordNotification extends Notification
{
    use Queueable;

    public function __construct(public string $token) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $deepLink = 'flymate://reset-password?token=' . $this->token . '&email=' . urlencode($notifiable->email);

        return (new MailMessage)
            ->subject(__('notifications.reset_subject'))
            ->line(__('notifications.reset_line1'))
            ->action(__('notifications.reset_action'), $deepLink)
            ->line(__('notifications.reset_line2'));
    }

    public function toArray(object $notifiable): array
    {
        return [];
    }
}
