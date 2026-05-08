import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onFilterPressed;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SearchBar(
        controller: controller,
        hintText: 'Search flights…',
        leading: Icon(Icons.search_rounded, color: colorScheme.primary),
        trailing: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
            onPressed: onFilterPressed,
            tooltip: 'Filters',
          ),
        ],
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(
          colorScheme.surfaceContainerHighest.withOpacity(0.5),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}