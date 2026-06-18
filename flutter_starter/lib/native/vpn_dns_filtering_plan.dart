class VpnDnsFilteringPlan {
  static const nativeComponents = [
    'FocusShieldVpnService',
    'DnsPacketParser',
    'DomainDecisionBridge',
    'VpnPermissionActivity',
    'VpnStatusReceiver',
  ];

  static const filteringFlow = [
    'User enables protection in Flutter',
    'Flutter requests Android VPN permission',
    'Native Android starts FocusShieldVpnService',
    'VPN service observes DNS/domain request metadata',
    'Native layer sends domain to Flutter bridge or local engine bridge',
    'ProtectionEngine checks settings and repositories',
    'ALLOW returns request to normal network path',
    'BLOCK prevents request and logs blocked attempt',
    'Flutter shows intervention screen',
  ];

  static const safetyRules = [
    'Do not start VPN before database and protection engine are ready',
    'Do not log exact domains when privacy mode is stats-only',
    'Do not store packet contents',
    'Do not inspect message content',
    'Only domain-level metadata belongs in the protection engine',
    'User must clearly enable protection',
    'User must be able to see protection status',
    'Delayed disable must protect turning off filtering',
  ];
}
