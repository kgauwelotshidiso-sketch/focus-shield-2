import 'package:flutter/material.dart';

class FocusShieldBottomNav extends StatelessWidget {
  const FocusShieldBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.shield_rounded), label: 'Scanner'),
        NavigationDestination(icon: Icon(Icons.spa_rounded), label: 'Recovery'),
        NavigationDestination(icon: Icon(Icons.trending_up_rounded), label: 'Progress'),
        NavigationDestination(icon: Icon(Icons.psychology_rounded), label: 'Coach'),
        NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
      ],
    );
  }
}
