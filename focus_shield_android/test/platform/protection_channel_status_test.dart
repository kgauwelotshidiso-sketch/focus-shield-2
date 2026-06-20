import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/platform/protection_channel.dart';

void main() {
  test('ProtectionStatus reads DNS forwarder skeleton status safely', () {
    final status = ProtectionStatus.fromMap(
      <Object?, Object?>{
        'nativeStatusVersion': 7,
        'protectionMode': 'stopped',
        'vpnActive': false,
        'blocklistLoaded': true,
        'blockedDomainCount': 3,
        'nativeDnsReady': true,
        'nativeLoadedDomainCount': 3,
        'packetLoopPrepared': true,
        'packetLoopRunning': false,
        'packetsObserved': 0,
        'ipPacketsObserved': 0,
        'ipv6PacketsObserved': 0,
        'udpPacketsObserved': 0,
        'ipv6UdpPacketsObserved': 0,
        'tcpPacketsObserved': 0,
        'ipv6TcpPacketsObserved': 0,
        'dnsCandidatePacketsObserved': 0,
        'ipv6DnsCandidatePacketsObserved': 0,
        'dnsParseAttempts': 0,
        'dnsParseFailures': 0,
        'lastPacketProtocol': 'live_read_disabled',
        'lastParserError': '',
        'lastPacketSummary': 'packet_loop_prepared_not_reading',
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
        'dnsForwarderPrepared': true,
        'dnsForwarderEnabled': false,
        'dnsForwarderMode': 'dns_forwarder_skeleton_only',
        'upstreamPrimary': '1.1.1.1',
        'upstreamFallback': '8.8.8.8',
        'forwardAttempts': 0,
        'forwardSuccesses': 0,
        'forwardFailures': 0,
        'lastForwarderDecision':
            'dns_forwarder_skeleton_prepared_no_network_forwarding',
        'lastForwarderError': '',
        'liveTrafficReadEnabled': false,
        'blockingEnabled': false,
        'liveObservationToggleAvailable': true,
        'liveObservationRequested': false,
        'liveObservationGateVersion': 2,
        'liveObservationCodeGateReady': true,
        'liveObservationCodeGateUnlocked': true,
        'liveObservationSafetyGate': 'unlocked_by_code',
        'liveObservationUnlockAttempts': 0,
        'statusMessage': 'Native protection is stopped.',
        'blocklistError': '',
      },
    );

    expect(status.nativeStatusVersion, 7);
    expect(status.dnsForwarderPrepared, true);
    expect(status.dnsForwarderEnabled, false);
    expect(status.dnsForwarderMode, 'dns_forwarder_skeleton_only');
    expect(status.upstreamPrimary, '1.1.1.1');
    expect(status.upstreamFallback, '8.8.8.8');
    expect(status.forwardAttempts, 0);
    expect(status.forwardSuccesses, 0);
    expect(status.forwardFailures, 0);
    expect(status.lastForwarderDecision,
        'dns_forwarder_skeleton_prepared_no_network_forwarding');
    expect(status.liveTrafficReadEnabled, false);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
  });

  test('ProtectionStatus handles missing native map safely', () {
    final status = ProtectionStatus.fromMap(null);

    expect(status.nativeStatusVersion, 0);
    expect(status.protectionMode, 'unavailable');
    expect(status.vpnActive, false);
    expect(status.dnsForwarderPrepared, false);
    expect(status.dnsForwarderEnabled, false);
    expect(status.dnsForwarderMode, '');
    expect(status.upstreamPrimary, '');
    expect(status.upstreamFallback, '');
    expect(status.forwardAttempts, 0);
    expect(status.forwardSuccesses, 0);
    expect(status.forwardFailures, 0);
    expect(status.liveTrafficReadEnabled, false);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
    expect(status.statusMessage, 'Native protection status is unavailable.');
  });
}
