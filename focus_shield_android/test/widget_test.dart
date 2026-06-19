import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_shield_android/app.dart';
import 'package:focus_shield_android/data/repositories/in_memory_app_state_repository.dart';

void main() {
  const protectionChannel = MethodChannel('focus_shield/protection');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(protectionChannel, (call) async {
          switch (call.method) {
            case 'protectionStatus':
              return <String, Object>{
                'nativeStatusVersion': 2,
                'protectionMode': 'dry_run_prepared',
                'vpnActive': false,
                'blocklistLoaded': true,
                'blockedDomainCount': 0,
                'nativeDnsReady': false,
                'nativeLoadedDomainCount': 0,
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
                'liveObservationRequested': false,
                'liveObservationSafetyGate': 'locked_until_android_sdk_testing',
                'statusMessage': 'Test native status ready.',
                'blocklistError': '',
              };
            case 'startProtection':
              return 'started';
            case 'stopProtection':
              return 'stopped';
            case 'reloadBlocklist':
              return 'reloaded';
            case 'prepareLiveObservation':
              return 'observation_prepared_locked';
            case 'disableLiveObservation':
              return 'observation_disabled';
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(protectionChannel, null);
  });

  testWidgets('Focus Shield app loads home screen', (tester) async {
    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Focus Shield'), findsWidgets);
  });
}
