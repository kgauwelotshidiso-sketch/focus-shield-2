import 'package:flutter/services.dart';

import 'method_channel_contract.dart';

class VpnMethodChannelBridge {
  static const MethodChannel _channel = MethodChannel(
    MethodChannelContract.vpnChannelName,
  );

  static const EventChannel _events = EventChannel(
    MethodChannelContract.vpnEventsChannelName,
  );

  Future<bool> requestVpnPermission() async {
    final result = await _channel.invokeMethod<bool>(
      MethodChannelContract.methodRequestVpnPermission,
    );

    return result ?? false;
  }

  Future<void> startVpn() async {
    await _channel.invokeMethod<void>(
      MethodChannelContract.methodStartVpn,
    );
  }

  Future<void> stopVpn() async {
    await _channel.invokeMethod<void>(
      MethodChannelContract.methodStopVpn,
    );
  }

  Future<bool> isVpnRunning() async {
    final result = await _channel.invokeMethod<bool>(
      MethodChannelContract.methodIsVpnRunning,
    );

    return result ?? false;
  }

  Future<String> getVpnStatus() async {
    final result = await _channel.invokeMethod<String>(
      MethodChannelContract.methodGetVpnStatus,
    );

    return result ?? MethodChannelContract.statusStopped;
  }

  Stream<dynamic> get vpnEvents {
    return _events.receiveBroadcastStream();
  }
}
