import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/platform/protection_channel.dart';

void main() {
  test('ProtectionStatus reads locked live observation code gate map', () {
    final status = ProtectionStatus.fromMap(
      <Object?, Object?>{
        'nativeStatusVersion': 3,
        'protectionMode': 'observation_prepared_locked',
        'vpnActive': true,
        'blocklistLoaded': true,
        'blockedDomainCount': 3,
        'nativeDnsReady': true,
        'nativeLoadedDomainCount': 3,
        'packetLoopPrepared': true,
        'packetLoopRunning': false,
        'packetsObserved': 0,
        'dnsParserPrepared': true,
        'dnsQueriesParsed': 0,
        'lastParsedHostname': '',
        'dryRunModeReady': true,
        'dryRunBlocksDetected': 0,
        'lastDryRunDecision': '',
        'liveTrafficReadEnabled': false,
        'blockingEnabled': false,
        'liveObservationToggleAvailable': true,
        'liveObservationRequested': true,
        'liveObservationGateVersion': 1,
        'liveObservationCodeGateReady': true,
        'liveObservationCodeGateUnlocked': false,
        'liveObservationSafetyGate':
            'locked_until_live_observation_regression_tests_are_documented',
        'liveObservationUnlockAttempts': 0,
        'statusMessage': 'Live observation code gate remains locked.',
        'blocklistError': '',
      },
    );

    expect(status.nativeStatusVersion, 3);
    expect(status.protectionMode, 'observation_prepared_locked');
    expect(status.vpnActive, true);
    expect(status.liveObservationGateVersion, 1);
    expect(status.liveObservationCodeGateReady, true);
    expect(status.liveObservationCodeGateUnlocked, false);
    expect(status.liveObservationRequested, true);
    expect(status.observationLocked, true);
    expect(status.liveTrafficReadEnabled, false);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
  });

  test('ProtectionStatus handles missing native map safely', () {
    final status = ProtectionStatus.fromMap(null);

    expect(status.nativeStatusVersion, 0);
    expect(status.protectionMode, 'unavailable');
    expect(status.vpnActive, false);
    expect(status.liveObservationToggleAvailable, false);
    expect(status.liveObservationRequested, false);
    expect(status.liveObservationGateVersion, 0);
    expect(status.liveObservationCodeGateReady, false);
    expect(status.liveObservationCodeGateUnlocked, false);
    expect(status.liveObservationUnlockAttempts, 0);
    expect(status.liveTrafficReadEnabled, false);
    expect(status.blockingEnabled, false);
    expect(status.isSafeMode, true);
    expect(status.statusMessage, 'Native protection status is unavailable.');
  });
}
