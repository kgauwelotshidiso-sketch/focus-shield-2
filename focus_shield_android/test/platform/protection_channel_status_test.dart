import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/platform/protection_channel.dart';

void main() {
  test('ProtectionStatus reads DNS diagnostic live observation map safely', () {
    final status = ProtectionStatus.fromMap(
      <Object?, Object?>{
        'nativeStatusVersion': 4,
        'protectionMode': 'live_observation_only',
        'vpnActive': true,
        'blocklistLoaded': true,
        'blockedDomainCount': 3,
        'nativeDnsReady': true,
        'nativeLoadedDomainCount': 3,
        'packetLoopPrepared': true,
        'packetLoopRunning': true,
        'packetsObserved': 10,
        'ipPacketsObserved': 10,
        'udpPacketsObserved': 4,
        'tcpPacketsObserved': 6,
        'dnsCandidatePacketsObserved': 1,
        'dnsParseAttempts': 1,
        'dnsParseFailures': 0,
        'lastPacketProtocol': 'dns_candidate',
        'lastParserError': '',
        'lastPacketSummary': 'dns_candidate_src_43000_dst_53',
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

    expect(status.nativeStatusVersion, 4);
    expect(status.protectionMode, 'live_observation_only');
    expect(status.vpnActive, true);
    expect(status.packetLoopRunning, true);
    expect(status.packetsObserved, 10);
    expect(status.ipPacketsObserved, 10);
    expect(status.udpPacketsObserved, 4);
    expect(status.tcpPacketsObserved, 6);
    expect(status.dnsCandidatePacketsObserved, 1);
    expect(status.dnsParseAttempts, 1);
    expect(status.dnsParseFailures, 0);
    expect(status.lastPacketProtocol, 'dns_candidate');
    expect(status.lastParserError, '');
    expect(status.dnsQueriesParsed, 1);
    expect(status.lastParsedHostname, 'blocked-example.com');
    expect(status.liveObservationCodeGateUnlocked, true);
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
    expect(status.udpPacketsObserved, 0);
    expect(status.tcpPacketsObserved, 0);
    expect(status.dnsCandidatePacketsObserved, 0);
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
