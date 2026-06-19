import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ShieldCard extends StatelessWidget {
  const ShieldCard({
    super.key,
    required this.child,
    this.borderColor = AppTheme.primary,
  });

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withOpacity(0.38)),
        gradient: LinearGradient(
          colors: [
            AppTheme.card,
            AppTheme.cardSoft.withOpacity(0.96),
          ],
        ),
      ),
      child: child,
    );
  }
}
