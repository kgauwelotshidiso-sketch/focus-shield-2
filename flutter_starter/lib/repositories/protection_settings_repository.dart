import '../models/protection_settings.dart';

class ProtectionSettingsRepository {
  Future<ProtectionSettings?> getSettings() async {
    // TODO: Query single protection_settings row.
    return null;
  }

  Future<void> saveSettings(ProtectionSettings settings) async {
    // TODO: Insert or update protection_settings row.
  }

  Future<void> setProtectionEnabled(bool enabled) async {
    // TODO: Update protection_enabled.
  }

  Future<void> setPrivacyMode(String privacyMode) async {
    // TODO: Update privacy_mode.
  }

  Future<void> requestDelayedDisable(DateTime requestedAt, DateTime availableAt) async {
    // TODO: Save disable request timestamps.
  }
}
