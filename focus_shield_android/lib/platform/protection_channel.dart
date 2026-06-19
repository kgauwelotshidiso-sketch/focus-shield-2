import 'package:flutter/services.dart';

class ProtectionStatus {
  const ProtectionStatus({
    required this.vpnActive,
    required this.blocklistLoaded,
    required this.blockedDomainCount,
    required this.nativeDnsReady,
    required this.nativeLoadedDomainCount,
    required this.packetLoopPrepared,
    required this.packetLoopRunning,
    required this.packetsObserved,
    required this.dnsParserPrepared,
    required this.dnsQueriesParsed,
    required this.lastParsedHostname,
    required this.dryRunModeReady,
    required this.dryRunBlocksDetected,
    required this.lastDryRunDecision,
    required this.blocklistError,
  });

  final bool vpnActive;
  final bool blocklistLoaded;
  final int blockedDomainCount;
  final bool nativeDnsReady;
  final int nativeLoadedDomainCount;
  final bool packetLoopPrepared;
  final bool packetLoopRunning;
  final int packetsObserved;
  final bool dnsParserPrepared;
  final int dnsQueriesParsed;
  final String lastParsedHostname;
  final bool dryRunModeReady;
  final int dryRunBlocksDetected;
  final String lastDryRunDecision;
  final String blocklistError;

  factory ProtectionStatus.fromMap(Map<Object?, Object?>? map) {
    if (map == null) {
      return const ProtectionStatus(
        vpnActive: false,
        blocklistLoaded: false,
        blockedDomainCount: 0,
        nativeDnsReady: false,
        nativeLoadedDomainCount: 0,
        packetLoopPrepared: false,
        packetLoopRunning: false,
        packetsObserved: 0,
        dnsParserPrepared: false,
        dnsQueriesParsed: 0,
        lastParsedHostname: '',
        dryRunModeReady: false,
        dryRunBlocksDetected: 0,
        lastDryRunDecision: '',
        blocklistError: '',
      );
    }

    return ProtectionStatus(
      vpnActive: map['vpnActive'] == true,
      blocklistLoaded: map['blocklistLoaded'] == true,
      blockedDomainCount: _readInt(map['blockedDomainCount']),
      nativeDnsReady: map['nativeDnsReady'] == true,
      nativeLoadedDomainCount: _readInt(map['nativeLoadedDomainCount']),
      packetLoopPrepared: map['packetLoopPrepared'] == true,
      packetLoopRunning: map['packetLoopRunning'] == true,
      packetsObserved: _readInt(map['packetsObserved']),
      dnsParserPrepared: map['dnsParserPrepared'] == true,
      dnsQueriesParsed: _readInt(map['dnsQueriesParsed']),
      lastParsedHostname: _readString(map['lastParsedHostname']),
      dryRunModeReady: map['dryRunModeReady'] == true,
      dryRunBlocksDetected: _readInt(map['dryRunBlocksDetected']),
      lastDryRunDecision: _readString(map['lastDryRunDecision']),
      blocklistError: _readString(map['blocklistError']),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static String _readString(Object? value) {
    if (value is String) {
      return value;
    }

    return '';
  }
}

class ProtectionChannel {
  ProtectionChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('focus_shield/protection');

  final MethodChannel _channel;

  Future<String> startProtection() async {
    final response = await _channel.invokeMethod<String>('startProtection');
    return response ?? 'unknown';
  }

  Future<String> stopProtection() async {
    final response = await _channel.invokeMethod<String>('stopProtection');
    return response ?? 'unknown';
  }

  Future<String> reloadBlocklist() async {
    final response = await _channel.invokeMethod<String>('reloadBlocklist');
    return response ?? 'unknown';
  }

  Future<ProtectionStatus> protectionStatus() async {
    final response = await _channel.invokeMapMethod<Object?, Object?>(
      'protectionStatus',
    );

    return ProtectionStatus.fromMap(response);
  }
}
