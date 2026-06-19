import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/platform/protection_channel.dart';

void main() {
  test('ProtectionStatus reads full native dry-run status map', () {
    final status = ProtectionStatus.fromMap(<Object?, Object?>{
      'vpnActive': true,
      'blocklistLoaded': true,
      'blockedDomainCount': 4,
      'nativeDnsReady': true,
      'nativeLoadedDomainCount': 4,
      'packetLoopPrepared': true,
      'packetLoopRunning': false,
      'packetsObserved': 12,
      'dnsParserPrepared': true,
      'dnsQueriesParsed': 3,
      'lastParsedHostname': 'blocked-example.com',
      'dryRunModeReady': true,
      'dryRunBlocksDetected': 2,
      'lastDryRunDecision': 'would_block:blocked-example.com',
      'blocklistError': '',
    });

    expect(status.vpnActive, true);
    expect(status.blocklistLoaded, true);
    expect(status.blockedDomainCount, 4);
    expect(status.nativeDnsReady, true);
    expect(status.nativeLoadedDomainCount, 4);
    expect(status.packetLoopPrepared, true);
    expect(status.packetLoopRunning, false);
    expect(status.packetsObserved, 12);
    expect(status.dnsParserPrepared, true);
    expect(status.dnsQueriesParsed, 3);
    expect(status.lastParsedHostname, 'blocked-example.com');
    expect(status.dryRunModeReady, true);
    expect(status.dryRunBlocksDetected, 2);
    expect(status.lastDryRunDecision, 'would_block:blocked-example.com');
    expect(status.blocklistError, '');
  });

  test('ProtectionStatus handles missing native map safely', () {
    final status = ProtectionStatus.fromMap(null);

    expect(status.vpnActive, false);
    expect(status.blocklistLoaded, false);
    expect(status.blockedDomainCount, 0);
    expect(status.nativeDnsReady, false);
    expect(status.packetLoopPrepared, false);
    expect(status.dnsParserPrepared, false);
    expect(status.dryRunModeReady, false);
    expect(status.lastDryRunDecision, '');
  });
}
