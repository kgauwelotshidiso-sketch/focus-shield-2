import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'shield_card.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ShieldCard(
      borderColor: AppTheme.secondary,
      child: Column(
        children: [
          Icon(icon, size: 54, color: AppTheme.secondary),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
