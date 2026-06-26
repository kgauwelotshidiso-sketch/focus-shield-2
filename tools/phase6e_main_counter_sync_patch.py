from pathlib import Path

ROOT = Path("focus_shield_android")


def write(path: str, text: str) -> None:
    full_path = ROOT / path
    full_path.parent.mkdir(parents=True, exist_ok=True)
    full_path.write_text(text.strip() + "\n", encoding="utf-8")
    print(f"wrote {full_path}")


def patch_file(path: str, transform) -> None:
    full_path = ROOT / path
    text = full_path.read_text(encoding="utf-8")
    new_text = transform(text)
    if new_text == text:
        print(f"no change needed for {full_path}")
    else:
        full_path.write_text(new_text, encoding="utf-8")
        print(f"patched {full_path}")


write("lib/presentation/widgets/protection_chain_status_card.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';
import 'stat_grid.dart';

class ProtectionChainStatusCard extends StatefulWidget {
  const ProtectionChainStatusCard({
    super.key,
    this.compact = false,
    this.showControls = true,
    this.blockedDomains = const <String>[],
  });

  final bool compact;
  final bool showControls;
  final List<String> blockedDomains;

  @override
  State<ProtectionChainStatusCard> createState() =>
      _ProtectionChainStatusCardState();
}

class _ProtectionChainStatusCardState extends State<ProtectionChainStatusCard> {
  final ProtectionChannel _channel = ProtectionChannel();

  Map<String, dynamic> _status = <String, dynamic>{};
  bool _loading = true;
  String _message = 'Reading native protection chain...';

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    if (widget.blockedDomains.isNotEmpty) {
      _syncNativeBlocklist();
    }
  }

  Future<void> _refreshStatus() async {
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _loading = false;
      _message = 'Protection chain status refreshed.';
    });
  }

  Future<void> _syncNativeBlocklist() async {
    final domains = widget.blockedDomains
        .map((domain) => domain.trim().toLowerCase())
        .where((domain) => domain.isNotEmpty)
        .toSet()
        .toList();

    final result = await _channel.syncAccessibilityBlocklist(domains);
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _loading = false;
      _message = result;
    });
  }

  String _value(String key, {String fallback = '0'}) {
    final value = _status[key];

    if (value == null) {
      return fallback;
    }

    final clean = value.toString().trim();

    if (clean.isEmpty) {
      return fallback;
    }

    return clean;
  }

  int _intValue(String key) {
    final raw = _status[key];

    if (raw is int) return raw;
    if (raw is num) return raw.toInt();

    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  bool get _hasNativeActivity {
    return _intValue('events') > 0 ||
        _intValue('websitesScanned') > 0 ||
        _intValue('blockedDetections') > 0;
  }

  bool get _hasBlockedSite {
    return _value('lastDecision', fallback: '').toLowerCase() == 'blocked' &&
        _value('lastDomain', fallback: '').isNotEmpty;
  }

  String get _chainStatus {
    if (_hasBlockedSite) {
      return 'Blocking';
    }

    if (_hasNativeActivity) {
      return 'Active';
    }

    return 'Ready';
  }

  Color get _statusColor {
    if (_hasBlockedSite) return AppTheme.danger;
    if (_hasNativeActivity) return AppTheme.primary;
    return AppTheme.warning;
  }

  String get _lastBlockedSite {
    if (!_hasBlockedSite) return 'None';

    return _value('lastDomain', fallback: 'None');
  }

  @override
  Widget build(BuildContext context) {
    return ShieldCard(
      borderColor: _statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.compact ? 'Protection Sync' : 'Protection Chain Status'),
          const SizedBox(height: 12),
          StatGrid(
            items: {
              'Chain': _loading ? 'Loading' : _chainStatus,
              'Scanned': _value('websitesScanned'),
              'New': _value('newWebsitesScanned'),
              'Blocked': _value('blockedDetections'),
              if (!widget.compact) 'Unknown': _value('unknownDetections'),
              if (!widget.compact) 'Native DB': _value('nativeBlocklistDomains'),
            },
          ),
          const SizedBox(height: 12),
          Text('Last blocked site: $_lastBlockedSite'),
          const SizedBox(height: 6),
          Text(
            'Last action: ${_value('lastAction', fallback: 'No action yet')}',
          ),
          if (!widget.compact) ...[
            const SizedBox(height: 6),
            Text(_value('lastMessage', fallback: _message)),
          ],
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: 'Refresh Protection Status',
              subtitle: 'Sync native Accessibility counters',
              onPressed: _refreshStatus,
            ),
            if (widget.blockedDomains.isNotEmpty) ...[
              const SizedBox(height: 10),
              ActionButton(
                label: 'Sync Blocklist',
                subtitle: '${widget.blockedDomains.length} saved domain(s)',
                onPressed: _syncNativeBlocklist,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
''')
def add_import_if_missing(text: str, import_line: str) -> str:
    if import_line in text:
        return text

    lines = text.splitlines()
    last_import_index = -1

    for index, line in enumerate(lines):
        if line.strip().startswith("import "):
            last_import_index = index

    if last_import_index == -1:
        return import_line + "\n\n" + text

    lines.insert(last_import_index + 1, import_line)
    return "\n".join(lines) + "\n"


def inject_widget_into_first_listview(
    text: str,
    widget_code: str,
    duplicate_guard: str,
) -> str:
    if duplicate_guard in text:
        return text

    listview_index = text.find("return ListView(")
    if listview_index == -1:
        listview_index = text.find("ListView(")

    if listview_index == -1:
        return text

    children_index = text.find("children: [", listview_index)
    if children_index == -1:
        return text

    insert_index = children_index + len("children: [")
    return (
        text[:insert_index]
        + "\n"
        + widget_code
        + text[insert_index:]
    )


def patch_home_screen(text: str) -> str:
    text = add_import_if_missing(
        text,
        "import '../widgets/protection_chain_status_card.dart';",
    )

    widget_code = """        const ProtectionChainStatusCard(
          compact: true,
          showControls: false,
        ),
        const SizedBox(height: 16),
"""

    return inject_widget_into_first_listview(
        text=text,
        widget_code=widget_code,
        duplicate_guard="ProtectionChainStatusCard(",
    )


patch_file("lib/presentation/screens/home_screen.dart", patch_home_screen)


def patch_scanner_screen(text: str) -> str:
    text = add_import_if_missing(
        text,
        "import '../widgets/protection_chain_status_card.dart';",
    )

    widget_code = """        const ProtectionChainStatusCard(
          compact: true,
          showControls: false,
        ),
        const SizedBox(height: 16),
"""

    return inject_widget_into_first_listview(
        text=text,
        widget_code=widget_code,
        duplicate_guard="ProtectionChainStatusCard(",
    )


patch_file("lib/presentation/screens/scanner_screen.dart", patch_scanner_screen)


def patch_progress_screen(text: str) -> str:
    text = add_import_if_missing(
        text,
        "import '../widgets/protection_chain_status_card.dart';",
    )

    widget_code = """        const ProtectionChainStatusCard(
          compact: true,
          showControls: false,
        ),
        const SizedBox(height: 16),
"""

    return inject_widget_into_first_listview(
        text=text,
        widget_code=widget_code,
        duplicate_guard="ProtectionChainStatusCard(",
    )


patch_file("lib/presentation/screens/progress_screen.dart", patch_progress_screen)


write("lib/presentation/widgets/latest_blocked_site_card.dart", r'''
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../platform/protection_channel.dart';
import 'action_button.dart';
import 'shield_card.dart';

class LatestBlockedSiteCard extends StatefulWidget {
  const LatestBlockedSiteCard({
    super.key,
    this.showControls = true,
  });

  final bool showControls;

  @override
  State<LatestBlockedSiteCard> createState() => _LatestBlockedSiteCardState();
}

class _LatestBlockedSiteCardState extends State<LatestBlockedSiteCard> {
  final ProtectionChannel _channel = ProtectionChannel();

  Map<String, dynamic> _status = <String, dynamic>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final status = await _channel.accessibilityDetectionStatus();

    if (!mounted) return;

    setState(() {
      _status = status;
      _loading = false;
    });
  }

  String _value(String key, {String fallback = ''}) {
    final value = _status[key];

    if (value == null) return fallback;

    final clean = value.toString().trim();

    if (clean.isEmpty) return fallback;

    return clean;
  }

  bool get _hasBlockedSite {
    return _value('lastDecision').toLowerCase() == 'blocked' &&
        _value('lastDomain').isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ShieldCard(
        borderColor: AppTheme.warning,
        child: Text('Loading latest protection activity...'),
      );
    }

    if (!_hasBlockedSite) {
      return ShieldCard(
        borderColor: AppTheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last blocked site'),
            const SizedBox(height: 8),
            const Text('No blocked site recorded yet.'),
            if (widget.showControls) ...[
              const SizedBox(height: 12),
              ActionButton(
                label: 'Refresh',
                subtitle: 'Check native Accessibility status',
                onPressed: _refresh,
              ),
            ],
          ],
        ),
      );
    }

    final domain = _value('lastDomain', fallback: 'Unknown');
    final category = _value('lastCategory', fallback: 'unknown');
    final score = _value('lastScore', fallback: '0');
    final packageName = _value('lastPackage', fallback: '-');
    final action = _value('lastAction', fallback: '-');

    return ShieldCard(
      borderColor: AppTheme.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last blocked site'),
          const SizedBox(height: 8),
          Text('Domain: $domain'),
          Text('Category: $category'),
          Text('Risk score: $score/100'),
          Text('Source: $packageName'),
          Text('Last action: $action'),
          const SizedBox(height: 10),
          const Text(
            'Focus Shield detected and interrupted this site through Accessibility.',
          ),
          if (widget.showControls) ...[
            const SizedBox(height: 12),
            ActionButton(
              label: 'Refresh',
              subtitle: 'Update latest blocked site',
              onPressed: _refresh,
            ),
          ],
        ],
      ),
    );
  }
}
''')
def patch_home_latest_blocked_site(text: str) -> str:
    text = add_import_if_missing(
        text,
        "import '../widgets/latest_blocked_site_card.dart';",
    )

    if "LatestBlockedSiteCard(" in text:
        return text

    marker = """        const ProtectionChainStatusCard(
          compact: true,
          showControls: false,
        ),
        const SizedBox(height: 16),
"""

    replacement = """        const ProtectionChainStatusCard(
          compact: true,
          showControls: false,
        ),
        const SizedBox(height: 16),
        const LatestBlockedSiteCard(
          showControls: false,
        ),
        const SizedBox(height: 16),
"""

    if marker in text:
        return text.replace(marker, replacement, 1)

    widget_code = """        const LatestBlockedSiteCard(
          showControls: false,
        ),
        const SizedBox(height: 16),
"""

    return inject_widget_into_first_listview(
        text=text,
        widget_code=widget_code,
        duplicate_guard="LatestBlockedSiteCard(",
    )


patch_file("lib/presentation/screens/home_screen.dart", patch_home_latest_blocked_site)


def patch_accessibility_detection_screen_counter_sync_note(text: str) -> str:
    if "Main app counter sync" in text:
        return text

    marker = """        ShieldCard(
          borderColor: AppTheme.primary,
          child: const Text(
            'Phase 6D ignores Android System UI rescans, syncs the saved blocklist into native Accessibility detection, and opens a real intervention screen after blocked detection.',
          ),
        ),"""

    replacement = """        ShieldCard(
          borderColor: AppTheme.primary,
          child: const Text(
            'Phase 6D ignores Android System UI rescans, syncs the saved blocklist into native Accessibility detection, and opens a real intervention screen after blocked detection.',
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Main app counter sync is active. Home, Scanner, and Progress can now read native Accessibility scanned, new, blocked, unknown, and last blocked site data.',
          ),
        ),"""

    if marker in text:
        return text.replace(marker, replacement, 1)

    return text


patch_file(
    "lib/presentation/screens/accessibility_detection_screen.dart",
    patch_accessibility_detection_screen_counter_sync_note,
)


def patch_scanner_native_counter_label(text: str) -> str:
    if "Native Accessibility counters are shown above" in text:
        return text

    marker = """        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Phase 5 is local-only. No paid API, no cloud dependency, and no VPN route changes.',
          ),
        ),"""

    replacement = """        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Phase 5 is local-only. No paid API, no cloud dependency, and no VPN route changes.',
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: const Text(
            'Native Accessibility counters are shown above through Protection Chain Status.',
          ),
        ),"""

    if marker in text:
        return text.replace(marker, replacement, 1)

    return text


patch_file("lib/presentation/screens/scanner_screen.dart", patch_scanner_native_counter_label)


def patch_progress_native_counter_label(text: str) -> str:
    if "Native protection activity is synced above" in text:
        return text

    marker = """        ShieldCard(
          borderColor: AppTheme.primary,
          child: const Text(
            'Phase 6C keeps detection local, fixes the overflow bug, and improves blocked-site feedback through app launch, toast, and notification fallback.',
          ),
        ),"""

    replacement = """        ShieldCard(
          borderColor: AppTheme.primary,
          child: const Text(
            'Phase 6C keeps detection local, fixes the overflow bug, and improves blocked-site feedback through app launch, toast, and notification fallback.',
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: const Text(
            'Native protection activity is synced above through Protection Chain Status.',
          ),
        ),"""

    if marker in text:
        return text.replace(marker, replacement, 1)

    return text


patch_file("lib/presentation/screens/progress_screen.dart", patch_progress_native_counter_label)

print("Phase 6E main counter sync patch completed successfully.")
write("test/widget_test.dart", r'''
import 'package:flutter/material.dart';
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
          return <String, dynamic>{
            'nativeStatusVersion': 7,
            'protectionMode': 'dry_run_prepared',
            'vpnActive': false,
            'blocklistLoaded': true,
            'blockedDomainCount': 3,
            'nativeDnsReady': false,
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
            'lastPacketProtocol': '',
            'lastParserError': '',
            'lastPacketSummary': '',
            'dnsParserPrepared': true,
            'dnsQueriesParsed': 0,
            'lastParsedHostname': '',
            'dryRunModeReady': true,
            'dryRunBlocksDetected': 0,
            'lastDryRunDecision': '',
            'dnsProxyPrepared': true,
            'dnsProxyRunning': false,
            'dnsProxyMode': 'disabled',
            'dnsProxyQueriesReceived': 0,
            'dnsProxyQueriesForwarded': 0,
            'dnsProxyResponsesReturned': 0,
            'dnsProxyErrors': 0,
            'lastDnsProxyHost': '',
            'lastDnsProxyDecision': '',
            'lastDnsProxyError': '',
            'dnsForwarderPrepared': true,
            'dnsForwarderEnabled': false,
            'dnsForwarderMode': 'diagnostic_only',
            'upstreamPrimary': '1.1.1.1',
            'upstreamFallback': '8.8.8.8',
            'forwardAttempts': 0,
            'forwardSuccesses': 0,
            'forwardFailures': 0,
            'lastForwarderDecision': '',
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
            'statusMessage': 'Test native status ready.',
            'blocklistError': '',
          };

        case 'accessibilityDetectionStatus':
          return <String, dynamic>{
            'events': 7,
            'websitesScanned': 7,
            'newWebsitesScanned': 1,
            'blockedDetections': 7,
            'unknownDetections': 0,
            'nativeBlocklistDomains': 3,
            'lastDomain': 'adult-risk-example.com',
            'lastCategory': 'adult-content',
            'lastDecision': 'blocked',
            'lastScore': 75,
            'lastConfidence': 75,
            'lastSignals': <String>['High-risk signal: adult'],
            'lastDetectedAt': 0,
            'lastPackage': 'com.android.chrome',
            'lastAction': 'opened_intervention',
            'lastMessage':
                'Focus Shield opened native intervention screen after blocked detection: adult-risk-example.com',
            'mode': 'local_detection',
          };

        case 'syncAccessibilityBlocklist':
          return 'accessibility_blocklist_synced:3';

        case 'resetAccessibilityDetections':
          return 'accessibility_detections_reset';

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

        case 'openAccessibilitySettings':
          return 'accessibility_settings_opened';

        case 'openVpnSettings':
          return 'vpn_settings_opened';

        case 'requestLiveObservationUnlock':
          return 'phase3_paused_unlock_not_required';

        case 'testDnsForwarder':
          return 'dns_forwarder_diagnostic_success';

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
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      FocusShieldApp(repository: InMemoryAppStateRepository()),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Focus Shield'), findsWidgets);
    expect(find.text('Protection Chain Status'), findsWidgets);
  });
}
''')

print("Phase 6E widget test hotfix applied successfully.")
def remove_unused_material_import_from_widget_test(text: str) -> str:
    return text.replace("import 'package:flutter/material.dart';\n", "")


patch_file(
    "test/widget_test.dart",
    remove_unused_material_import_from_widget_test,
)

print("Phase 6E unused widget test import removed successfully.")


