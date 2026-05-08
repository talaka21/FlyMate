import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fly_mate/core/routing/app_routes.dart';
import 'package:fly_mate/features/home/presentation/widgets/quick_action.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickAction(
            icon: Icons.qr_code_rounded,
            label: 'Check-In',
            onTap: () => context.push(AppRoutes.checkIn),
          ),
          QuickAction(
            icon: Icons.radar_rounded,
            label: 'Status',
            onTap: () => context.push(AppRoutes.flightStatus),
          ),
          QuickAction(
            icon: Icons.luggage_rounded,
            label: 'Baggage',
            onTap: () => context.push(AppRoutes.baggage),
          ),
          QuickAction(
            icon: Icons.airline_seat_recline_extra_rounded,
            label: 'Change Seat',
            onTap: () => context.push(AppRoutes.changeSeat),
          ),
        ],
      ),
    );
  }
}
