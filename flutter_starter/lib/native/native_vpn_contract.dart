class NativeVpnContract {
  static const channelName = 'focus_shield/vpn';

  static const startVpn = 'startVpn';
  static const stopVpn = 'stopVpn';
  static const isVpnRunning = 'isVpnRunning';
  static const requestVpnPermission = 'requestVpnPermission';

  static const onBlockedDomain = 'onBlockedDomain';
  static const onVpnStatusChanged = 'onVpnStatusChanged';

  static const eventDomain = 'domain';
  static const eventCategory = 'category';
  static const eventReason = 'reason';
  static const eventConfidence = 'confidence';
  static const eventTimestamp = 'timestamp';
}
