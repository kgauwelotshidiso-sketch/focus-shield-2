import 'package:flutter/services.dart';

class VpnServiceChannel {
  static const _channel = MethodChannel('focus_shield/vpn_service');

  Future<bool> startVpnService() async {
    final result = await _channel.invokeMethod<bool>('startVpnService');
    return result ?? false;
  }

  Future<bool> stopVpnService() async {
    final result = await _channel.invokeMethod<bool>('stopVpnService');
    return result ?? false;
  }

  Future<bool> isVpnRunning() async {
    final result = await _channel.invokeMethod<bool>('isVpnRunning');
    return result ?? false;
  }
}
