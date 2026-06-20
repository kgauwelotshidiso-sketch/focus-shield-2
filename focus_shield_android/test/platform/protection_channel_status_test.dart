import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/platform/protection_channel.dart';

void main() {
  test('ProtectionStatus reads IPv6 diagnostic live observation map safely', () {
    final status = ProtectionStatus.fromMap(
      <Object?, Object?>{
        'nativeStatusVersion': 5,
        'protectionMode': 'live_observation_only',
        'vpnActive': true,
        'blocklistLoaded': true,
        'blockedDomainCount': 3,
        'nativeDnsReady': true,
        'nativeLoadedDomainCount': 3,
        'packetLoopPrepared': true,
        'packetLoopRunning': true,
        'packetsObserved': 10,
        'ipPacketsObserved': 0,
        'ipv6PacketsObserved': 10,
        'udpPacketsObserved': 0,
        'ipv6UdpPacketsObserved': 4,
        'tcpPacketsObserved': 0,
        'ipv6TcpPacketsObserved': 6,
        'dnsCandidatePacketsObserved': 1,
        'ipv6DnsCandidatePacketsObserved': 1,
        'dnsParseAttempts': 1,
        'dnsParseFailures': 0,
        'lastPacketProtocol': 'ipv6_dns_candidate',
        'lastParserError': '',
        'lastPacketSummary': 'ipv6_dns_candidate_src_43000_dst_53',
        'dnsParserPrepared': true,
        'dnsQueriesParsed': 1,
        'lastParsedHostname': 'blocked-example.com',
        'dryRunModeReady': true,
        'dryRunBlocksDetected': 1,
        'lastDryRunDecision': 'would_block:blocked-example.com',
        'liveTrafficReadEnabled': true,
        'blockingEnabled': false,
        'liveObservationToggleAvailable': true,
        'liveObservationRequested': true,
        'liveObservationGateVersion': 2,
        'liveObservationCodeGateReady': true,
        'liveObservationCodeGateUnlocked': true,
        'liveObservationSafetyGate': 'unlocked_by_code',
        'liveObservationUnlockAttempts': 0,
        'statusMessage':
            'Live observation code gate is unlocked for observation only. Blocking remains disabled.',
        'blocklistError': '',
      },
    );

    expect(status.nativeStatusVersion, 5);
    expect(status.protectionMode, 'live_observation_only');
    expect(status.vpnActive, true);
    expect(status.packetLoopRunning, true);
    expect(status.packetsObserved, 10);
    expect(status.ipPacketsObserved, 0);
    expect(status.ipv6PacketsObserved, 10);
    expect(status.udpPacketsObserved, 0);
    expect(status.ipv6UdpPacketsObserved, 4);
    expect(status.tcpPacketsObserved, 0);
    expect(status.ipv6TcpPacketsObserved, 6);
    expect(status.dnsCandidatePacketsObserved, 1);
    expect(status.ipv6DnsCandidatePacketsObserved, 1);
    expect(status.dnsParseAttempts, 1);
    expect(status.dnsParseFailures, 0);
    expect(status.lastPacketProtocol, 'ipv6_dns_candidate');
    expect(status.lastParserError, '');
    expect(status.dnsQueriesParsed, 1);
    expect(status.lastParsedHostname, 'blocked-example.com');
    expect(status.liveTrafficReadEnabled, true);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
  });

  test('ProtectionStatus handles missing native map safely', () {
    final status = ProtectionStatus.fromMap(null);

    expect(status.nativeStatusVersion, 0);
    expect(status.protectionMode, 'unavailable');
    expect(status.vpnActive, false);
    expect(status.packetLoopRunning, false);
    expect(status.packetsObserved, 0);
    expect(status.ipPacketsObserved, 0);
    expect(status.ipv6PacketsObserved, 0);
    expect(status.udpPacketsObserved, 0);
    expect(status.ipv6UdpPacketsObserved, 0);
    expect(status.tcpPacketsObserved, 0);
    expect(status.ipv6TcpPacketsObserved, 0);
    expect(status.dnsCandidatePacketsObserved, 0);
    expect(status.ipv6DnsCandidatePacketsObserved, 0);
    expect(status.dnsParseAttempts, 0);
    expect(status.dnsParseFailures, 0);
    expect(status.lastPacketProtocol, '');
    expect(status.lastParserError, '');
    expect(status.liveTrafficReadEnabled, false);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
    expect(status.statusMessage, 'Native protection status is unavailable.');
  });
}
