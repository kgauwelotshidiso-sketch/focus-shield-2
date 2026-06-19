import 'focus_shield_state.dart';

class AppSnapshot {
  const AppSnapshot({
    required this.state,
    required this.createdAt,
    required this.version,
  });

  final FocusShieldState state;
  final DateTime createdAt;
  final int version;
}
