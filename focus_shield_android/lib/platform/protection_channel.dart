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

  factory ProtectionStatus.fromMap(Map<Object?, Object?>? map) {
    if (map == null) {
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

    return ProtectionStatus(
      nativeStatusVersion: _readInt(map['nativeStatusVersion']),
      protectionMode: _readString(map['protectionMode']),
      vpnActive: _readBool(map['vpnActive']),
      blocklistLoaded: _readBool(map['blocklistLoaded']),
      blockedDomainCount: _readInt(map['blockedDomainCount']),
      nativeDnsReady: _readBool(map['nativeDnsReady']),
      nativeLoadedDomainCount: _readInt(map['nativeLoadedDomainCount']),
      packetLoopPrepared: _readBool(map['packetLoopPrepared']),
      packetLoopRunning: _readBool(map['packetLoopRunning']),
      packetsObserved: _readInt(map['packetsObserved']),
      dnsParserPrepared: _readBool(map['dnsParserPrepared']),
      dnsQueriesParsed: _readInt(map['dnsQueriesParsed']),
      lastParsedHostname: _readString(map['lastParsedHostname']),
      dryRunModeReady: _readBool(map['dryRunModeReady']),
      dryRunBlocksDetected: _readInt(map['dryRunBlocksDetected']),
      lastDryRunDecision: _readString(map['lastDryRunDecision']),
      liveTrafficReadEnabled: _readBool(map['liveTrafficReadEnabled']),
      blockingEnabled: _readBool(map['blockingEnabled']),
      liveObservationToggleAvailable: _readBool(
        map['liveObservationToggleAvailable'],
      ),
      liveObservationRequested: _readBool(map['liveObservationRequested']),
      liveObservationGateVersion: _readInt(map['liveObservationGateVersion']),
      liveObservationCodeGateReady: _readBool(map['liveObservationCodeGateReady']),
      liveObservationCodeGateUnlocked:
          _readBool(map['liveObservationCodeGateUnlocked']),
      liveObservationSafetyGate: _readString(map['liveObservationSafetyGate']),
      liveObservationUnlockAttempts: _readInt(map['liveObservationUnlockAttempts']),
      statusMessage: _readString(map['statusMessage']),
      blocklistError: _readString(map['blocklistError']),
    );
  }

  bool get isSafeMode {
    return !liveTrafficReadEnabled && !blockingEnabled;
  }

  bool get observationLocked {
    return liveObservationSafetyGate.isNotEmpty &&
        liveObservationSafetyGate != 'unlocked';
  }

  static bool _readBool(Object? value) {
    return value == true;
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

  Future<String> prepareLiveObservation() async {
    final response = await _channel.invokeMethod<String>(
      'prepareLiveObservation',
    );
    return response ?? 'unknown';
  }

  Future<String> disableLiveObservation() async {
    final response = await _channel.invokeMethod<String>(
      'disableLiveObservation',
    );
    return response ?? 'unknown';
  }

  Future<String> openVpnSettings() async {
    final response = await _channel.invokeMethod<String>('openVpnSettings');
    return response ?? 'unknown';
  }

  Future<ProtectionStatus> protectionStatus() async {
    final response = await _channel.invokeMapMethod<Object?, Object?>(
      'protectionStatus',
    );

    return ProtectionStatus.fromMap(response);
  }
}
