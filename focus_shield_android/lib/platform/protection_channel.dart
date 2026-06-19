import 'package:flutter/services.dart';

class ProtectionStatus {
  const ProtectionStatus({
    required this.vpnActive,
    required this.blocklistLoaded,
    required this.blockedDomainCount,
  });

  final bool vpnActive;
  final bool blocklistLoaded;
  final int blockedDomainCount;

  factory ProtectionStatus.fromMap(Map<Object?, Object?>? map) {
    if (map == null) {
      return const ProtectionStatus(
        vpnActive: false,
        blocklistLoaded: false,
        blockedDomainCount: 0,
      );
    }

    return ProtectionStatus(
      vpnActive: map['vpnActive'] == true,
      blocklistLoaded: map['blocklistLoaded'] == true,
      blockedDomainCount: _readInt(map['blockedDomainCount']),
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
