class NativeVpnServiceSkeletonPlan {
  static const skeletonFiles = [
    'FocusShieldVpnService.kt',
    'DnsPacketParser.kt',
    'DomainDecisionBridge.kt',
    'VpnPermissionActivity.kt',
    'VpnStatusReceiver.kt',
    'AndroidManifest_notes.xml',
  ];

  static const safeBuildOrder = [
    'Create non-active Kotlin skeleton files',
    'Define manifest service notes',
    'Define permission request activity',
    'Define VPN status receiver',
    'Define domain decision bridge',
    'Only later connect to real Flutter MethodChannel',
    'Only later implement DNS packet parsing',
    'Only later enable real VPN filtering',
  ];

  static const safetyLimits = [
    'No active VPN filtering in starter skeleton',
    'No private content inspection',
    'No full packet storage',
    'No direct SQLite writes from native layer',
    'No hidden protection state',
    'No instant disable bypass',
  ];
}
