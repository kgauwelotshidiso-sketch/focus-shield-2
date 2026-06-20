import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/platform/protection_channel.dart';

void main() {
  test('ProtectionStatus reads DNS proxy skeleton status safely', () {
    final status = ProtectionStatus.fromMap(
      <Object?, Object?>{
        'nativeStatusVersion': 6,
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
        'ipv6UdpPacketsObserved': 0,
        'tcpPacketsObserved': 0,
        'ipv6TcpPacketsObserved': 0,
        'dnsCandidatePacketsObserved': 0,
        'ipv6DnsCandidatePacketsObserved': 0,
        'dnsParseAttempts': 0,
        'dnsParseFailures': 0,
        'lastPacketProtocol': 'ipv6_icmpv6',
        'lastParserError': '',
        'lastPacketSummary': 'ipv6_icmpv6_packet_length_80',
        'dnsParserPrepared': true,
        'dnsQueriesParsed': 0,
        'lastParsedHostname': '',
        'dryRunModeReady': true,
        'dryRunBlocksDetected': 0,
        'lastDryRunDecision': '',
        'dnsProxyPrepared': true,
        'dnsProxyRunning': false,
        'dnsProxyMode': 'dns_proxy_diagnostic_only',
        'dnsProxyQueriesReceived': 0,
        'dnsProxyQueriesForwarded': 0,
        'dnsProxyResponsesReturned': 0,
        'dnsProxyErrors': 0,
        'lastDnsProxyHost': '',
        'lastDnsProxyDecision':
            'dns_forwarder_skeleton_ready_forwarding_disabled',
        'lastDnsProxyError': '',
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

    expect(status.nativeStatusVersion, 6);
    expect(status.dnsProxyPrepared, true);
    expect(status.dnsProxyRunning, false);
    expect(status.dnsProxyMode, 'dns_proxy_diagnostic_only');
    expect(status.dnsProxyQueriesReceived, 0);
    expect(status.dnsProxyQueriesForwarded, 0);
    expect(status.dnsProxyResponsesReturned, 0);
    expect(status.dnsProxyErrors, 0);
    expect(status.lastDnsProxyDecision,
        'dns_forwarder_skeleton_ready_forwarding_disabled');
    expect(status.liveTrafficReadEnabled, true);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
  });

  test('ProtectionStatus handles missing native map safely', () {
    final status = ProtectionStatus.fromMap(null);

    expect(status.nativeStatusVersion, 0);
    expect(status.protectionMode, 'unavailable');
    expect(status.vpnActive, false);
    expect(status.dnsProxyPrepared, false);
    expect(status.dnsProxyRunning, false);
    expect(status.dnsProxyMode, '');
    expect(status.dnsProxyQueriesReceived, 0);
    expect(status.dnsProxyQueriesForwarded, 0);
    expect(status.dnsProxyResponsesReturned, 0);
    expect(status.dnsProxyErrors, 0);
    expect(status.liveTrafficReadEnabled, false);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
    expect(status.statusMessage, 'Native protection status is unavailable.');
  });
}
