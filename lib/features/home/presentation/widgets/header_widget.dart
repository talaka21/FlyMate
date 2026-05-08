import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final int badgeCount;

  const HeaderWidget({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    // final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
