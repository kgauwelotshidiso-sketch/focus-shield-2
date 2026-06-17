import 'package:flutter/material.dart';

class ProtectionDashboardScreen extends StatelessWidget {
  const ProtectionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protection Dashboard')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Starter screen for Focus Shield Android version.'),
          ),
        ),
      ),
    );
  }
}
