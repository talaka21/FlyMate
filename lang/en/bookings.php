<?php

return [

    // ─── Success ───
    'created'       => 'Booking created successfully',
    'cancelled'     => 'Booking cancelled successfully',
    'rescheduled'   => 'Booking rescheduled successfully',
    'upgraded'      => 'Booking upgraded successfully',

    // ─── Errors ───
    'not_found'             => 'Booking not found.',
    'already_cancelled'     => 'Booking is already cancelled.',
    'cannot_cancel'         => 'This booking cannot be cancelled.',
    'cannot_reschedule'     => 'This booking cannot be rescheduled.',
    'cannot_upgrade'        => 'This booking cannot be upgraded.',
    'same_class'            => 'You are already in this class.',
    'no_seats'              => 'No available seats for the selected class.',
    'reschedule_too_late'   => 'Cannot reschedule within 24 hours of departure.',
    'upgrade_too_late'      => 'Cannot upgrade within 12 hours of departure.',

];
