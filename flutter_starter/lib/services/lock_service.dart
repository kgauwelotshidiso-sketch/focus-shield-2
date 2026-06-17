class LockService {
  Future<bool> verifyPin(String pin) async {
    return false;
  }

  Future<void> requestDelayedDisable() async {}

  Future<bool> canDisableProtectionNow() async {
    return false;
  }
}
