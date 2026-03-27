<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Authentication Language Lines
    |--------------------------------------------------------------------------
    |
    | The following language lines are used during authentication for various
    | messages that we need to display to the user. You are free to modify
    | these language lines according to your application's requirements.
    |
    */

    // ─── Laravel Default ───
    'failed'   => 'These credentials do not match our records.',
    'password' => 'The provided password is incorrect.',
    'throttle' => 'Too many login attempts. Please try again in :seconds seconds.',

    // ─── FlyMate: Register ───
    'account_created'           => 'Account created successfully',
    'registration_pending'      => 'Registration submitted. Waiting for admin approval.',

    // ─── Login ───
    'mfa_code_sent'             => 'MFA code sent',
    'logged_out'                => 'Logged out successfully',

    // ─── MFA ───
    'invalid_mfa'               => 'Invalid or expired MFA code.',

    // ─── Password Reset ───
    'reset_link_sent'           => 'Reset password link sent to your email.',
    'invalid_token'             => 'Invalid or expired token.',
    'token_expired'             => 'Token has expired.',
    'password_reset'            => 'Password reset successfully.',

    // ─── Errors ───
    'invalid_credentials'       => 'Invalid email or password.',
    'account_banned'            => 'Your account has been banned.',
    'account_pending'           => 'Your account is pending approval.',
    'unauthorized'              => 'Unauthorized.',
    'access_denied'             => 'Access Denied.',

];
