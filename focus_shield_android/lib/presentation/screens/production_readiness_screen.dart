import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';
import '../widgets/stat_grid.dart';

class ProductionReadinessScreen extends StatelessWidget {
  const ProductionReadinessScreen({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Production Readiness',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const Text('Android testing, build readiness, and release preparation'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: const StatGrid(
            items: {
              'Flutter App': 'Ready',
              'SQLite': 'Connected',
              'Tests': 'Active',
              'Android': 'Check',
            },
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Core MVP Status'),
              SizedBox(height: 8),
              Text('✅ Home dashboard connected'),
              Text('✅ Scanner connected to saved blocklist'),
              Text('✅ Intervention flow connected'),
              Text('✅ Recovery tracking connected'),
              Text('✅ Coach intelligence connected'),
              Text('✅ SQLite persistence connected'),
              Text('✅ Goals and affirmations connected'),
              Text('✅ Daily reset and streak system connected'),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.warning,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Android Reality Check'),
              SizedBox(height: 8),
              Text('The Flutter app is ready for Android testing.'),
              Text('Real system-wide blocking still needs the native Android VPN/DNS layer.'),
              Text('The current scanner is the app-level prototype protection engine.'),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terminal Commands'),
              SizedBox(height: 8),
              SelectableText('cd /workspaces/focus-shield-2/focus_shield_android'),
              SelectableText('flutter doctor -v'),
              SelectableText('flutter analyze'),
              SelectableText('flutter test'),
              SelectableText('flutter devices'),
              SelectableText('flutter run'),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: ActionButton(
            label: 'Back to Settings',
            subtitle: 'Return to control center',
            onPressed: onBack,
          ),
        ),
      ],
    );
  }
}
