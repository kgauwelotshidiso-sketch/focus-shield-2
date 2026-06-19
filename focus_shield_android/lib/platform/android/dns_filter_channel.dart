import 'package:flutter/services.dart';

class DnsFilterChannel {
  static const _channel = MethodChannel('focus_shield/dns_filter');

  Future<void> updateBlockedDomains(List<String> domains) async {
    await _channel.invokeMethod<void>('updateBlockedDomains', {
      'domains': domains,
    });
  }
}
