import 'package:flutter/services.dart';

class VpnBridge {
  static const MethodChannel _channel = MethodChannel('focus_shield/vpn');

  Future<void> startProtectionVpn() async {
    await _channel.invokeMethod('startVpn');
  }

  Future<void> stopProtectionVpn() async {
    await _channel.invokeMethod('stopVpn');
  }

  Future<bool> isVpnRunning() async {
    final result = await _channel.invokeMethod<bool>('isVpnRunning');
    return result ?? false;
  }
}
