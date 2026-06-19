import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/platform/protection_channel.dart';

void main() {
  test(
    'ProtectionStatus reads live observation toggle preparation status map',
    () {
      final status = ProtectionStatus.fromMap(<Object?, Object?>{
        'nativeStatusVersion': 2,
        'protectionMode': 'observation_prepared_locked',
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
        'liveTrafficReadEnabled': false,
        'blockingEnabled': false,
        'liveObservationToggleAvailable': true,
        'liveObservationRequested': true,
        'liveObservationSafetyGate': 'locked_until_android_sdk_testing',
        'statusMessage': 'Observation requested but safety gate is locked.',
        'blocklistError': '',
      });

      expect(status.nativeStatusVersion, 2);
      expect(status.protectionMode, 'observation_prepared_locked');
      expect(status.vpnActive, true);
      expect(status.blocklistLoaded, true);
      expect(status.blockedDomainCount, 4);
      expect(status.liveObservationToggleAvailable, true);
      expect(status.liveObservationRequested, true);
      expect(
        status.liveObservationSafetyGate,
        'locked_until_android_sdk_testing',
      );
      expect(status.observationLocked, true);
      expect(status.liveTrafficReadEnabled, false);
      expect(status.blockingEnabled, false);
      expect(status.isSafeMode, true);
      expect(
        status.statusMessage,
        'Observation requested but safety gate is locked.',
      );
    },
  );

  test('ProtectionStatus handles missing native map safely', () {
    final status = ProtectionStatus.fromMap(null);

    expect(status.nativeStatusVersion, 0);
    expect(status.protectionMode, 'unavailable');
    expect(status.vpnActive, false);
    expect(status.liveObservationToggleAvailable, false);
    expect(status.liveObservationRequested, false);
    expect(status.liveTrafficReadEnabled, false);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
    expect(status.statusMessage, 'Native protection status is unavailable.');
  });
}
