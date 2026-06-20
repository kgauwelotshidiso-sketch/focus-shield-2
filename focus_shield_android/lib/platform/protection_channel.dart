import 'package:flutter/services.dart';

class ProtectionStatus {
  const ProtectionStatus({
    required this.nativeStatusVersion,
    required this.protectionMode,
    required this.vpnActive,
    required this.blocklistLoaded,
    required this.blockedDomainCount,
    required this.nativeDnsReady,
    required this.nativeLoadedDomainCount,
    required this.packetLoopPrepared,
    required this.packetLoopRunning,
    required this.packetsObserved,
    required this.ipPacketsObserved,
    required this.udpPacketsObserved,
    required this.tcpPacketsObserved,
    required this.dnsCandidatePacketsObserved,
    required this.dnsParseAttempts,
    required this.dnsParseFailures,
    required this.lastPacketProtocol,
    required this.lastParserError,
    required this.lastPacketSummary,
    required this.dnsParserPrepared,
    required this.dnsQueriesParsed,
    required this.lastParsedHostname,
    required this.dryRunModeReady,
    required this.dryRunBlocksDetected,
    required this.lastDryRunDecision,
    required this.liveTrafficReadEnabled,
    required this.blockingEnabled,
    required this.liveObservationToggleAvailable,
    required this.liveObservationRequested,
    required this.liveObservationGateVersion,
    required this.liveObservationCodeGateReady,
    required this.liveObservationCodeGateUnlocked,
    required this.liveObservationSafetyGate,
    required this.liveObservationUnlockAttempts,
    required this.statusMessage,
    required this.blocklistError,
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
  final int udpPacketsObserved;
  final int tcpPacketsObserved;
  final int dnsCandidatePacketsObserved;
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

  bool get observationLocked {
    final normalizedGate = liveObservationSafetyGate.trim().toLowerCase();

    if (liveObservationCodeGateUnlocked) {
      return false;
    }

    if (normalizedGate == 'unlocked_by_code') {
      return false;
    }

    if (normalizedGate.startsWith('unlocked')) {
      return false;
    }

    return normalizedGate.isNotEmpty;
  }

  bool get isSafeMode {
    return blockingEnabled == false;
  }

  factory ProtectionStatus.fromMap(Object? raw) {
    if (raw is! Map) {
      return ProtectionStatus.unavailable();
    }

    return ProtectionStatus(
      nativeStatusVersion: _readInt(raw['nativeStatusVersion']),
      protectionMode: _readString(raw['protectionMode']),
      vpnActive: _readBool(raw['vpnActive']),
      blocklistLoaded: _readBool(raw['blocklistLoaded']),
      blockedDomainCount: _readInt(raw['blockedDomainCount']),
      nativeDnsReady: _readBool(raw['nativeDnsReady']),
      nativeLoadedDomainCount: _readInt(raw['nativeLoadedDomainCount']),
      packetLoopPrepared: _readBool(raw['packetLoopPrepared']),
      packetLoopRunning: _readBool(raw['packetLoopRunning']),
      packetsObserved: _readInt(raw['packetsObserved']),
      ipPacketsObserved: _readInt(raw['ipPacketsObserved']),
      udpPacketsObserved: _readInt(raw['udpPacketsObserved']),
      tcpPacketsObserved: _readInt(raw['tcpPacketsObserved']),
      dnsCandidatePacketsObserved:
          _readInt(raw['dnsCandidatePacketsObserved']),
      dnsParseAttempts: _readInt(raw['dnsParseAttempts']),
      dnsParseFailures: _readInt(raw['dnsParseFailures']),
      lastPacketProtocol: _readString(raw['lastPacketProtocol']),
      lastParserError: _readString(raw['lastParserError']),
      lastPacketSummary: _readString(raw['lastPacketSummary']),
      dnsParserPrepared: _readBool(raw['dnsParserPrepared']),
      dnsQueriesParsed: _readInt(raw['dnsQueriesParsed']),
      lastParsedHostname: _readString(raw['lastParsedHostname']),
      dryRunModeReady: _readBool(raw['dryRunModeReady']),
      dryRunBlocksDetected: _readInt(raw['dryRunBlocksDetected']),
      lastDryRunDecision: _readString(raw['lastDryRunDecision']),
      liveTrafficReadEnabled: _readBool(raw['liveTrafficReadEnabled']),
      blockingEnabled: _readBool(raw['blockingEnabled']),
      liveObservationToggleAvailable:
          _readBool(raw['liveObservationToggleAvailable']),
      liveObservationRequested: _readBool(raw['liveObservationRequested']),
      liveObservationGateVersion: _readInt(raw['liveObservationGateVersion']),
      liveObservationCodeGateReady:
          _readBool(raw['liveObservationCodeGateReady']),
      liveObservationCodeGateUnlocked:
          _readBool(raw['liveObservationCodeGateUnlocked']),
      liveObservationSafetyGate: _readString(raw['liveObservationSafetyGate']),
      liveObservationUnlockAttempts:
          _readInt(raw['liveObservationUnlockAttempts']),
      statusMessage: _readString(raw['statusMessage']),
      blocklistError: _readString(raw['blocklistError']),
    );
  }

  factory ProtectionStatus.unavailable() {
    return const ProtectionStatus(
      nativeStatusVersion: 0,
      protectionMode: 'unavailable',
      vpnActive: false,
      blocklistLoaded: false,
      blockedDomainCount: 0,
      nativeDnsReady: false,
      nativeLoadedDomainCount: 0,
      packetLoopPrepared: false,
      packetLoopRunning: false,
      packetsObserved: 0,
      ipPacketsObserved: 0,
      udpPacketsObserved: 0,
      tcpPacketsObserved: 0,
      dnsCandidatePacketsObserved: 0,
      dnsParseAttempts: 0,
      dnsParseFailures: 0,
      lastPacketProtocol: '',
      lastParserError: '',
      lastPacketSummary: '',
      dnsParserPrepared: false,
      dnsQueriesParsed: 0,
      lastParsedHostname: '',
      dryRunModeReady: false,
      dryRunBlocksDetected: 0,
      lastDryRunDecision: '',
      liveTrafficReadEnabled: false,
      blockingEnabled: false,
      liveObservationToggleAvailable: false,
      liveObservationRequested: false,
      liveObservationGateVersion: 0,
      liveObservationCodeGateReady: false,
      liveObservationCodeGateUnlocked: false,
      liveObservationSafetyGate: '',
      liveObservationUnlockAttempts: 0,
      statusMessage: 'Native protection status is unavailable.',
      blocklistError: '',
    );
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static bool _readBool(Object? value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }

  static String _readString(Object? value) {
    return value?.toString() ?? '';
  }
}

class ProtectionChannel {
  static const MethodChannel _channel = MethodChannel('focus_shield/protection');

  Future<String> startProtection() async {
    return _invokeString('startProtection');
  }

  Future<String> stopProtection() async {
    return _invokeString('stopProtection');
  }

  Future<ProtectionStatus> protectionStatus() async {
    final result = await _channel.invokeMethod<Object?>('protectionStatus');
    return ProtectionStatus.fromMap(result);
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

  Future<String> requestLiveObservationUnlock() async {
    return _invokeString('requestLiveObservationUnlock');
  }

  Future<String> _invokeString(String method) async {
    final result = await _channel.invokeMethod<Object?>(method);
    return result?.toString() ?? '';
  }
}
