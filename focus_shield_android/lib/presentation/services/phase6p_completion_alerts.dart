import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Phase6PCompletionAlerts {
  const Phase6PCompletionAlerts._();

  static Future<void> play(BuildContext context, String message) async {
    try {
      await HapticFeedback.vibrate();
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // Some devices/emulators may block sound or haptics.
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
