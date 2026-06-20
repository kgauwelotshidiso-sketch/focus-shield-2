import 'package:flutter/material.dart';

import '../../platform/protection_channel.dart';

class ProtectionStatusCard extends StatefulWidget {
  const ProtectionStatusCard({super.key, this.protectionChannel});

  final ProtectionChannel? protectionChannel;

  @override
  State<ProtectionStatusCard> createState() => _ProtectionStatusCardState();
}

class _ProtectionStatusCardState extends State<ProtectionStatusCard> {
  late final ProtectionChannel _protectionChannel;

  ProtectionStatus _status = const ProtectionStatus(
    nativeStatusVersion: 0,
    protectionMode: 'unavailable',
    vpnActive: false,
    blocklistLoaded: false,
    blockedDomainCount: 0,
    nativeDnsReady: false,
    nativeLoadedDomainCount: 0,
    packetLoopPrepared: false,
    packetLoopRunning: false,
    packetsObserved: 0,
    ipPacketsObserved: 0,
    udpPacketsObserved: 0,
    tcpPacketsObserved: 0,
    dnsCandidatePacketsObserved: 0,
    dnsParseAttempts: 0,
    dnsParseFailures: 0,
    lastPacketProtocol: '',
    lastParserError: '',
    lastPacketSummary: '',
    dnsParserPrepared: false,
    dnsQueriesParsed: 0,
    lastParsedHostname: '',
    dryRunModeReady: false,
    dryRunBlocksDetected: 0,
    lastDryRunDecision: '',
    liveTrafficReadEnabled: false,
    blockingEnabled: false,
    liveObservationToggleAvailable: false,
    liveObservationRequested: false,
    liveObservationGateVersion: 0,
    liveObservationCodeGateReady: false,
    liveObservationCodeGateUnlocked: false,
    liveObservationSafetyGate: '',
    liveObservationUnlockAttempts: 0,
    statusMessage: 'Native protection status is unavailable.',
    blocklistError: '',
  );

  bool _loading = false;
  String _message = 'Protection bridge ready.';

  @override
  void initState() {
    super.initState();
    _protectionChannel = widget.protectionChannel ?? ProtectionChannel();
    _refreshStatus();
  }

  Future<void> _runAction(Future<String> Function() action) async {
    setState(() {
      _loading = true;
      _message = 'Working...';
    });

    try {
      final response = await action();

      if (!mounted) {
        return;
      }

      setState(() {
        _message = _readableMessage(response);
      });

      await _refreshStatus(showLoading: false);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _message =
            'Native protection bridge is not available in this environment.';
        _loading = false;
      });
    }
  }

  Future<void> _refreshStatus({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final nextStatus = await _protectionChannel.protectionStatus();

      if (!mounted) {
        return;
      }

      setState(() {
        _status = nextStatus;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _message =
            'Native protection bridge is not available in this environment.';
        _loading = false;
      });
    }
  }

  String _readableMessage(String response) {
    switch (response) {
      case 'started':
        return 'Protection start command sent.';
      case 'stopped':
        return 'Protection stop command sent.';
      case 'reloaded':
        return 'Blocklist reload command sent.';
      case 'permission_required':
        return 'Android VPN permission is required before protection can start.';
      case 'observation_prepared_locked':
        return 'Observation request prepared. Check the live status above; blocking remains disabled.';
      case 'observation_disabled':
        return 'Live observation request cleared. Blocking remains disabled.';
      case 'vpn_settings_opened':
        return 'Android VPN settings opened.';
      case 'vpn_settings_unavailable':
        return 'Android VPN settings could not be opened.';
      case 'vpn_permission_screen_requested':
        return 'VPN permission screen requested. If nothing appears, tap Open VPN Settings.';
      default:
        return 'Native response: $response';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocklistError = _status.blocklistError;
    final lastParsedHostname = _status.lastParsedHostname;
    final lastDryRunDecision = _status.lastDryRunDecision;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Native Protection', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              _status.statusMessage.isEmpty
                  ? 'Android VPN filtering bridge status and controls.'
                  : _status.statusMessage,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _StatusRow(
              label: 'Native status version',
              value: _status.nativeStatusVersion.toString(),
            ),
            _StatusRow(label: 'Protection mode', value: _status.protectionMode),
            _StatusRow(
              label: 'Safe mode',
              value: _status.isSafeMode ? 'On' : 'Off',
            ),
            _StatusRow(
              label: 'Observation toggle',
              value: _status.liveObservationToggleAvailable
                  ? (_status.liveObservationRequested
                        ? 'Requested'
                        : 'Available')
                  : 'Unavailable',
            ),
            _StatusRow(
              label: 'Observation safety gate',
              value: _status.observationLocked ? 'Locked' : 'Unlocked',
            ),
            _StatusRow(
              label: 'Code gate ready',
              value: _status.liveObservationCodeGateReady ? 'Yes' : 'No',
            ),
            _StatusRow(
              label: 'Code gate unlocked',
              value: _status.liveObservationCodeGateUnlocked ? 'Yes' : 'No',
            ),
            _StatusRow(
              label: 'Gate version',
              value: _status.liveObservationGateVersion.toString(),
            ),
            _StatusRow(
              label: 'Unlock attempts',
              value: _status.liveObservationUnlockAttempts.toString(),
            ),
            _StatusRow(
              label: 'Live traffic reading',
              value: _status.liveTrafficReadEnabled ? 'Enabled' : 'Disabled',
            ),
            _StatusRow(
              label: 'Blocking',
              value: _status.blockingEnabled ? 'Enabled' : 'Disabled',
            ),
            _StatusRow(
              label: 'VPN service',
              value: _status.vpnActive ? 'Active' : 'Inactive',
            ),
            _StatusRow(
              label: 'Blocklist',
              value: _status.blocklistLoaded ? 'Loaded' : 'Not loaded',
            ),
            _StatusRow(
              label: 'Saved blocked domains',
              value: _status.blockedDomainCount.toString(),
            ),
            _StatusRow(
              label: 'Native DNS filter',
              value: _status.nativeDnsReady ? 'Ready' : 'Waiting',
            ),
            _StatusRow(
              label: 'Packet loop',
              value: _status.packetLoopPrepared
                  ? (_status.packetLoopRunning ? 'Running' : 'Prepared')
                  : 'Not prepared',
            ),
            _StatusRow(
              label: 'DNS parser',
              value: _status.dnsParserPrepared ? 'Prepared' : 'Not prepared',
            ),
            _StatusRow(
              label: 'Dry-run mode',
              value: _status.dryRunModeReady ? 'Ready' : 'Not ready',
            ),
            _StatusRow(
              label: 'Packets observed',
              value: _status.packetsObserved.toString(),
            ),
            _StatusRow(
              label: 'IPv4 packets observed',
              value: _status.ipPacketsObserved.toString(),
            ),
            _StatusRow(
              label: 'IPv6 packets observed',
              value: _status.ipv6PacketsObserved.toString(),
            ),
            _StatusRow(
              label: 'IPv4 UDP packets',
              value: _status.udpPacketsObserved.toString(),
            ),
            _StatusRow(
              label: 'IPv6 UDP packets',
              value: _status.ipv6UdpPacketsObserved.toString(),
            ),
            _StatusRow(
              label: 'IPv4 TCP packets',
              value: _status.tcpPacketsObserved.toString(),
            ),
            _StatusRow(
              label: 'IPv6 TCP packets',
              value: _status.ipv6TcpPacketsObserved.toString(),
            ),
            _StatusRow(
              label: 'DNS candidates',
              value: _status.dnsCandidatePacketsObserved.toString(),
            ),
            _StatusRow(
              label: 'IPv6 DNS candidates',
              value: _status.ipv6DnsCandidatePacketsObserved.toString(),
            ),
            _StatusRow(
              label: 'DNS parse attempts',
              value: _status.dnsParseAttempts.toString(),
            ),
            _StatusRow(
              label: 'DNS parse failures',
              value: _status.dnsParseFailures.toString(),
            ),
            _StatusRow(
              label: 'Last packet protocol',
              value: _status.lastPacketProtocol.isEmpty
                  ? '-'
                  : _status.lastPacketProtocol,
            ),
            _StatusRow(
              label: 'Last parser error',
              value: _status.lastParserError.isEmpty
                  ? '-'
                  : _status.lastParserError,
            ),
            _StatusRow(
              label: 'DNS proxy prepared',
              value: _status.dnsProxyPrepared ? 'Yes' : 'No',
            ),
            _StatusRow(
              label: 'DNS proxy running',
              value: _status.dnsProxyRunning ? 'Yes' : 'No',
            ),
            _StatusRow(
              label: 'DNS proxy mode',
              value: _status.dnsProxyMode.isEmpty ? '-' : _status.dnsProxyMode,
            ),
            _StatusRow(
              label: 'Proxy queries received',
              value: _status.dnsProxyQueriesReceived.toString(),
            ),
            _StatusRow(
              label: 'Proxy queries forwarded',
              value: _status.dnsProxyQueriesForwarded.toString(),
            ),
            _StatusRow(
              label: 'Proxy responses returned',
              value: _status.dnsProxyResponsesReturned.toString(),
            ),
            _StatusRow(
              label: 'Proxy errors',
              value: _status.dnsProxyErrors.toString(),
            ),
            _StatusRow(
              label: 'Last proxy decision',
              value: _status.lastDnsProxyDecision.isEmpty
                  ? '-'
                  : _status.lastDnsProxyDecision,
            ),
            _StatusRow(
              label: 'DNS queries parsed',
              value: _status.dnsQueriesParsed.toString(),
            ),
            _StatusRow(
              label: 'Dry-run would-block count',
              value: _status.dryRunBlocksDetected.toString(),
            ),
            if (lastParsedHostname.isNotEmpty)
              _StatusRow(label: 'Last parsed host', value: lastParsedHostname),
            if (lastDryRunDecision.isNotEmpty)
              _StatusRow(
                label: 'Last dry-run decision',
                value: lastDryRunDecision,
              ),
            if (blocklistError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Blocklist note: $blocklistError'),
            ],
            const SizedBox(height: 12),
            Text(_message),
            const SizedBox(height: 16),
            if (_loading)
              const LinearProgressIndicator()
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        _runAction(_protectionChannel.startProtection),
                    icon: const Icon(Icons.shield_rounded),
                    label: const Text('Start Protection'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _runAction(_protectionChannel.prepareLiveObservation),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Prepare Observation'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _runAction(_protectionChannel.disableLiveObservation),
                    icon: const Icon(Icons.visibility_off_rounded),
                    label: const Text('Disable Observation'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _runAction(_protectionChannel.stopProtection),
                    icon: const Icon(Icons.stop_circle_rounded),
                    label: const Text('Stop'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _runAction(_protectionChannel.reloadBlocklist),
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Reload Blocklist'),
                  ),
                  TextButton.icon(
                    onPressed: _refreshStatus,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
