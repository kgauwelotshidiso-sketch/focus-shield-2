import 'package:flutter/services.dart';

class ProtectionStatus {
  const ProtectionStatus({
    this.nativeStatusVersion = 0,
    this.protectionMode = 'unavailable',
    this.vpnActive = false,
    this.blocklistLoaded = false,
    this.blockedDomainCount = 0,
    this.nativeDnsReady = false,
    this.nativeLoadedDomainCount = 0,
    this.packetLoopPrepared = false,
    this.packetLoopRunning = false,
    this.packetsObserved = 0,
    this.ipPacketsObserved = 0,
    this.ipv6PacketsObserved = 0,
    this.udpPacketsObserved = 0,
    this.ipv6UdpPacketsObserved = 0,
    this.tcpPacketsObserved = 0,
    this.ipv6TcpPacketsObserved = 0,
    this.dnsCandidatePacketsObserved = 0,
    this.ipv6DnsCandidatePacketsObserved = 0,
    this.dnsParseAttempts = 0,
    this.dnsParseFailures = 0,
    this.lastPacketProtocol = '',
    this.lastParserError = '',
    this.lastPacketSummary = '',
    this.dnsParserPrepared = false,
    this.dnsQueriesParsed = 0,
    this.lastParsedHostname = '',
    this.dryRunModeReady = false,
    this.dryRunBlocksDetected = 0,
    this.lastDryRunDecision = '',
    this.dnsProxyPrepared = false,
    this.dnsProxyRunning = false,
    this.dnsProxyMode = '',
    this.dnsProxyQueriesReceived = 0,
    this.dnsProxyQueriesForwarded = 0,
    this.dnsProxyResponsesReturned = 0,
    this.dnsProxyErrors = 0,
    this.lastDnsProxyHost = '',
    this.lastDnsProxyDecision = '',
    this.lastDnsProxyError = '',
    this.dnsForwarderPrepared = false,
    this.dnsForwarderEnabled = false,
    this.dnsForwarderMode = '',
    this.upstreamPrimary = '',
    this.upstreamFallback = '',
    this.forwardAttempts = 0,
    this.forwardSuccesses = 0,
    this.forwardFailures = 0,
    this.lastForwarderDecision = '',
    this.lastForwarderError = '',
    this.liveTrafficReadEnabled = false,
    this.blockingEnabled = false,
    this.liveObservationToggleAvailable = false,
    this.liveObservationRequested = false,
    this.liveObservationGateVersion = 0,
    this.liveObservationCodeGateReady = false,
    this.liveObservationCodeGateUnlocked = false,
    this.liveObservationSafetyGate = '',
    this.liveObservationUnlockAttempts = 0,
    this.statusMessage = 'Native protection status is unavailable.',
    this.blocklistError = '',
  });

  final int nativeStatusVersion;
  final String protectionMode;
  final bool vpnActive;
  final bool blocklistLoaded;
  final int blockedDomainCount;
  final bool nativeDnsReady;
  final int nativeLoadedDomainCount;
  final bool packetLoopPrepared;
  final bool packetLoopRunning;
  final int packetsObserved;
  final int ipPacketsObserved;
  final int ipv6PacketsObserved;
  final int udpPacketsObserved;
  final int ipv6UdpPacketsObserved;
  final int tcpPacketsObserved;
  final int ipv6TcpPacketsObserved;
  final int dnsCandidatePacketsObserved;
  final int ipv6DnsCandidatePacketsObserved;
  final int dnsParseAttempts;
  final int dnsParseFailures;
  final String lastPacketProtocol;
  final String lastParserError;
  final String lastPacketSummary;
  final bool dnsParserPrepared;
  final int dnsQueriesParsed;
  final String lastParsedHostname;
  final bool dryRunModeReady;
  final int dryRunBlocksDetected;
  final String lastDryRunDecision;
  final bool dnsProxyPrepared;
  final bool dnsProxyRunning;
  final String dnsProxyMode;
  final int dnsProxyQueriesReceived;
  final int dnsProxyQueriesForwarded;
  final int dnsProxyResponsesReturned;
  final int dnsProxyErrors;
  final String lastDnsProxyHost;
  final String lastDnsProxyDecision;
  final String lastDnsProxyError;
  final bool dnsForwarderPrepared;
  final bool dnsForwarderEnabled;
  final String dnsForwarderMode;
  final String upstreamPrimary;
  final String upstreamFallback;
  final int forwardAttempts;
  final int forwardSuccesses;
  final int forwardFailures;
  final String lastForwarderDecision;
  final String lastForwarderError;
  final bool liveTrafficReadEnabled;
  final bool blockingEnabled;
  final bool liveObservationToggleAvailable;
  final bool liveObservationRequested;
  final int liveObservationGateVersion;
  final bool liveObservationCodeGateReady;
  final bool liveObservationCodeGateUnlocked;
  final String liveObservationSafetyGate;
  final int liveObservationUnlockAttempts;
  final String statusMessage;
  final String blocklistError;

  bool get isSafeMode {
    return !blockingEnabled ||
        protectionMode.contains('dry_run') ||
        protectionMode.contains('stopped') ||
        protectionMode.contains('paused') ||
        protectionMode.contains('unavailable');
  }

  bool get observationLocked {
    final gate = liveObservationSafetyGate.toLowerCase();
    return gate.contains('locked') && !liveObservationCodeGateUnlocked;
  }

  factory ProtectionStatus.fromMap(dynamic raw) {
    final map = raw is Map
        ? raw.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    return ProtectionStatus(
      nativeStatusVersion: _readInt(map, 'nativeStatusVersion'),
      protectionMode: _readString(
        map,
        'protectionMode',
        fallback: 'unavailable',
      ),
      vpnActive: _readBool(map, 'vpnActive'),
      blocklistLoaded: _readBool(map, 'blocklistLoaded'),
      blockedDomainCount: _readInt(map, 'blockedDomainCount'),
      nativeDnsReady: _readBool(map, 'nativeDnsReady'),
      nativeLoadedDomainCount: _readInt(map, 'nativeLoadedDomainCount'),
      packetLoopPrepared: _readBool(map, 'packetLoopPrepared'),
      packetLoopRunning: _readBool(map, 'packetLoopRunning'),
      packetsObserved: _readInt(map, 'packetsObserved'),
      ipPacketsObserved: _readInt(map, 'ipPacketsObserved'),
      ipv6PacketsObserved: _readInt(map, 'ipv6PacketsObserved'),
      udpPacketsObserved: _readInt(map, 'udpPacketsObserved'),
      ipv6UdpPacketsObserved: _readInt(map, 'ipv6UdpPacketsObserved'),
      tcpPacketsObserved: _readInt(map, 'tcpPacketsObserved'),
      ipv6TcpPacketsObserved: _readInt(map, 'ipv6TcpPacketsObserved'),
      dnsCandidatePacketsObserved: _readInt(map, 'dnsCandidatePacketsObserved'),
      ipv6DnsCandidatePacketsObserved: _readInt(
        map,
        'ipv6DnsCandidatePacketsObserved',
      ),
      dnsParseAttempts: _readInt(map, 'dnsParseAttempts'),
      dnsParseFailures: _readInt(map, 'dnsParseFailures'),
      lastPacketProtocol: _readString(map, 'lastPacketProtocol'),
      lastParserError: _readString(map, 'lastParserError'),
      lastPacketSummary: _readString(map, 'lastPacketSummary'),
      dnsParserPrepared: _readBool(map, 'dnsParserPrepared'),
      dnsQueriesParsed: _readInt(map, 'dnsQueriesParsed'),
      lastParsedHostname: _readString(map, 'lastParsedHostname'),
      dryRunModeReady: _readBool(map, 'dryRunModeReady'),
      dryRunBlocksDetected: _readInt(map, 'dryRunBlocksDetected'),
      lastDryRunDecision: _readString(map, 'lastDryRunDecision'),
      dnsProxyPrepared: _readBool(map, 'dnsProxyPrepared'),
      dnsProxyRunning: _readBool(map, 'dnsProxyRunning'),
      dnsProxyMode: _readString(map, 'dnsProxyMode'),
      dnsProxyQueriesReceived: _readInt(map, 'dnsProxyQueriesReceived'),
      dnsProxyQueriesForwarded: _readInt(map, 'dnsProxyQueriesForwarded'),
      dnsProxyResponsesReturned: _readInt(map, 'dnsProxyResponsesReturned'),
      dnsProxyErrors: _readInt(map, 'dnsProxyErrors'),
      lastDnsProxyHost: _readString(map, 'lastDnsProxyHost'),
      lastDnsProxyDecision: _readString(map, 'lastDnsProxyDecision'),
      lastDnsProxyError: _readString(map, 'lastDnsProxyError'),
      dnsForwarderPrepared: _readBool(map, 'dnsForwarderPrepared'),
      dnsForwarderEnabled: _readBool(map, 'dnsForwarderEnabled'),
      dnsForwarderMode: _readString(map, 'dnsForwarderMode'),
      upstreamPrimary: _readString(map, 'upstreamPrimary'),
      upstreamFallback: _readString(map, 'upstreamFallback'),
      forwardAttempts: _readInt(map, 'forwardAttempts'),
      forwardSuccesses: _readInt(map, 'forwardSuccesses'),
      forwardFailures: _readInt(map, 'forwardFailures'),
      lastForwarderDecision: _readString(map, 'lastForwarderDecision'),
      lastForwarderError: _readString(map, 'lastForwarderError'),
      liveTrafficReadEnabled: _readBool(map, 'liveTrafficReadEnabled'),
      blockingEnabled: _readBool(map, 'blockingEnabled'),
      liveObservationToggleAvailable: _readBool(
        map,
        'liveObservationToggleAvailable',
      ),
      liveObservationRequested: _readBool(map, 'liveObservationRequested'),
      liveObservationGateVersion: _readInt(map, 'liveObservationGateVersion'),
      liveObservationCodeGateReady: _readBool(
        map,
        'liveObservationCodeGateReady',
      ),
      liveObservationCodeGateUnlocked: _readBool(
        map,
        'liveObservationCodeGateUnlocked',
      ),
      liveObservationSafetyGate: _readString(map, 'liveObservationSafetyGate'),
      liveObservationUnlockAttempts: _readInt(
        map,
        'liveObservationUnlockAttempts',
      ),
      statusMessage: _readString(
        map,
        'statusMessage',
        fallback: 'Native protection status is unavailable.',
      ),
      blocklistError: _readString(map, 'blocklistError'),
    );
  }

  static int _readInt(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  static bool _readBool(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value != 0;
    if (value is String) {
      final clean = value.toLowerCase();
      return clean == 'true' || clean == 'yes' || clean == '1';
    }

    return false;
  }

  static String _readString(
    Map<String, dynamic> map,
    String key, {
    String fallback = '',
  }) {
    final value = map[key];

    if (value == null) return fallback;

    return value.toString();
  }
}

class ProtectionChannel {
  factory ProtectionChannel() {
    return _instance;
  }

  ProtectionChannel._internal();

  static final ProtectionChannel _instance = ProtectionChannel._internal();

  static const MethodChannel _channel = MethodChannel(
    'focus_shield/protection',
  );

  Future<String> _invokeString(String method) async {
    try {
      final result = await _channel.invokeMethod<String>(method);
      return result ?? 'no_response';
    } catch (error) {
      return 'error:${error.runtimeType}';
    }
  }

  Future<Map<String, dynamic>> _invokeMap(String method) async {
    try {
      final result = await _channel.invokeMethod<dynamic>(method);

      if (result is Map) {
        return result.map((key, value) => MapEntry(key.toString(), value));
      }

      return <String, dynamic>{
        'error': 'unexpected_response',
        'method': method,
      };
    } catch (error) {
      return <String, dynamic>{
        'error': error.runtimeType.toString(),
        'method': method,
      };
    }
  }

  Future<String> startProtection() async {
    return _invokeString('startProtection');
  }

  Future<String> stopProtection() async {
    return _invokeString('stopProtection');
  }

  Future<ProtectionStatus> protectionStatus() async {
    final status = await _invokeMap('protectionStatus');
    return ProtectionStatus.fromMap(status);
  }

  Future<String> reloadBlocklist() async {
    return _invokeString('reloadBlocklist');
  }

  Future<String> prepareLiveObservation() async {
    return _invokeString('prepareLiveObservation');
  }

  Future<String> disableLiveObservation() async {
    return _invokeString('disableLiveObservation');
  }

  Future<String> openVpnSettings() async {
    return _invokeString('openVpnSettings');
  }

  Future<String> openAccessibilitySettings() async {
    return _invokeString('openAccessibilitySettings');
  }

  Future<String> requestLiveObservationUnlock() async {
    return _invokeString('requestLiveObservationUnlock');
  }

  Future<String> testDnsForwarder() async {
    return _invokeString('testDnsForwarder');
  }

  Future<Map<String, dynamic>> accessibilityDetectionStatus() async {
    return _invokeMap('accessibilityDetectionStatus');
  }

  Future<String> resetAccessibilityDetections() async {
    return _invokeString('resetAccessibilityDetections');
  }

  Future<String> syncAccessibilityBlocklist(List<String> domains) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'syncAccessibilityBlocklist',
        domains,
      );

      return result ?? 'accessibility_blocklist_sync_no_response';
    } catch (error) {
      return 'error:${error.runtimeType}';
    }
  }
}
