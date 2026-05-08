import 'package:flutter/material.dart';
import 'package:fly_mate/features/home/presentation/screens/home_page.dart';
import 'package:fly_mate/features/popular_stations/presentation/screens/pupular_stations_page.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DubaiCityGuide()),
        );
      },
      child: SizedBox(
        width: 140,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background image ──
              Image.network(
                destination.imageUrl,
                fit: BoxFit.cover,
                // Graceful fallback while loading / on error
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: destination.cardColor.withOpacity(0.4),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: destination.cardColor.withOpacity(0.6),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                    size: 36,
                  ),
                ),
              ),

              // ── Gradient overlay ──
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // ── Text labels ──
              Positioned(
                bottom: 14,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          destination.country,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
