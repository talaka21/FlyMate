import 'package:flutter/material.dart';
import 'package:fly_mate/core/routing/app_routes.dart';
import 'package:fly_mate/features/auth/presentation/pages/auth_screen.dart';
import 'package:fly_mate/features/home/presentation/screens/home_page.dart';
import 'package:fly_mate/features/auth/presentation/pages/login_screen.dart';
import 'package:fly_mate/features/auth/presentation/pages/otp_code_screen.dart';
import 'package:fly_mate/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:fly_mate/features/check_in/presentation/screens/check_in_page.dart';
import 'package:fly_mate/features/baggage/presentation/screens/baggage_page.dart';
import 'package:fly_mate/features/flight_status/presentation/screens/flight_status_page.dart';
import 'package:fly_mate/features/tickets/presentation/screens/tickets_page.dart';
import 'package:fly_mate/features/change_seat/presentation/screens/change_seat_page.dart';
import 'package:go_router/go_router.dart';
import 'package:fly_mate/features/auth/presentation/pages/forget_password_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.signIn,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: AppRoutes.signIn,
      name: 'signin',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
          transitionDuration: const Duration(milliseconds: 1000),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),

    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      builder: (context, state) {
        final email = state.extra as String;
        return OtpVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.signUp,
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.checkIn,
      name: 'checkIn',
      builder: (context, state) => const CheckInPage(),
    ),
    GoRoute(
      path: AppRoutes.baggage,
      name: 'baggage',
      builder: (context, state) => const BaggagePage(),
    ),
    GoRoute(
      path: AppRoutes.flightStatus,
      name: 'flightStatus',
      builder: (context, state) => const FlightStatusPage(),
    ),
    GoRoute(
      path: AppRoutes.tickets,
      name: 'tickets',
      builder: (context, state) => const TicketsPage(),
    ),
    GoRoute(
      path: AppRoutes.changeSeat,
      name: 'changeSeat',
      builder: (context, state) => const ChangeSeatPage(),
    ),
  ],
);
