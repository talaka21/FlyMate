<?php
namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class BoardingPassMail extends Mailable
{
    use Queueable, SerializesModels;

    public $booking;
    public $qrCode;

    public function __construct($booking, $qrCode)
    {
        $this->booking = $booking;
        $this->qrCode = $qrCode;
    }

  public function content(): \Illuminate\Mail\Mailables\Content
    {
        return new \Illuminate\Mail\Mailables\Content(
            view: 'emails.boarding_pass',
        );
    }
}
