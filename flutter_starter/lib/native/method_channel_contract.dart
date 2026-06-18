class MethodChannelContract {
  static const vpnChannelName = 'focus_shield/vpn';
  static const vpnEventsChannelName = 'focus_shield/vpn_events';

  static const methodRequestVpnPermission = 'requestVpnPermission';
  static const methodStartVpn = 'startVpn';
  static const methodStopVpn = 'stopVpn';
  static const methodIsVpnRunning = 'isVpnRunning';
  static const methodGetVpnStatus = 'getVpnStatus';

  static const eventBlockedDomain = 'onBlockedDomain';
  static const eventVpnStatusChanged = 'onVpnStatusChanged';
  static const eventVpnError = 'onVpnError';

  static const keyEventType = 'eventType';
  static const keyDomain = 'domain';
  static const keyCategory = 'category';
  static const keyReason = 'reason';
  static const keyConfidence = 'confidence';
  static const keyTimestamp = 'timestamp';
  static const keyStatus = 'status';
  static const keyMessage = 'message';
  static const keyErrorCode = 'errorCode';
  static const keyShouldBlock = 'shouldBlock';

  static const statusStopped = 'stopped';
  static const statusStarting = 'starting';
  static const statusRunning = 'running';
  static const statusStopping = 'stopping';
  static const statusError = 'error';

  static const errorPermissionDenied = 'permission_denied';
  static const errorServiceStartFailed = 'service_start_failed';
  static const errorEngineUnavailable = 'engine_unavailable';
  static const errorDatabaseUnavailable = 'database_unavailable';
}
