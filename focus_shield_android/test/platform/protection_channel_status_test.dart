import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/platform/protection_channel.dart';

void main() {
  test('ProtectionStatus reads unlocked live observation only map safely', () {
    final status = ProtectionStatus.fromMap(
      <Object?, Object?>{
        'nativeStatusVersion': 3,
        'protectionMode': 'live_observation_only',
        'vpnActive': true,
        'blocklistLoaded': true,
        'blockedDomainCount': 3,
        'nativeDnsReady': true,
        'nativeLoadedDomainCount': 3,
        'packetLoopPrepared': true,
        'packetLoopRunning': true,
        'packetsObserved': 0,
        'dnsParserPrepared': true,
        'dnsQueriesParsed': 0,
        'lastParsedHostname': '',
        'dryRunModeReady': true,
        'dryRunBlocksDetected': 0,
        'lastDryRunDecision': '',
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

    expect(status.nativeStatusVersion, 3);
    expect(status.protectionMode, 'live_observation_only');
    expect(status.vpnActive, true);
    expect(status.liveObservationGateVersion, 2);
    expect(status.liveObservationCodeGateReady, true);
    expect(status.liveObservationCodeGateUnlocked, true);
    expect(status.liveObservationRequested, true);
    expect(status.observationLocked, false);
    expect(status.liveTrafficReadEnabled, true);
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
