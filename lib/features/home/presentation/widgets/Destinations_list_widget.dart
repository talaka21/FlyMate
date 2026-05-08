// ignore: file_names
import 'package:flutter/material.dart';
import 'package:fly_mate/features/home/presentation/widgets/destination_card_widget.dart';

class DestinationsList extends StatelessWidget {
  final List<dynamic> destinations;

  const DestinationsList({super.key, required this.destinations});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return DestinationCard(destination: destinations[index]);
        },
      ),
    );
  }
}
