# Live Observation DNS Parser Findings

## Current Observation

Packets observed increased during live observation-only mode.

DNS queries parsed remained zero.

## Confirmed Working

- VPN shell activation
- Live observation-only mode
- Packet counter
- Stop command
- Safe shutdown
- Blocking disabled state

## Not Yet Confirmed

- Live DNS query extraction
- Last parsed hostname update
- Dry-run would-block detection from live DNS traffic

## Technical Direction

Before any blocking phase, add safer diagnostic counters:

- IP packets observed
- UDP packets observed
- TCP packets observed
- DNS candidate packets observed
- DNS parse attempts
- DNS parse failures
- Last parser error
- Last packet protocol

## Safety Rule

Diagnostics may inspect packet headers and DNS candidate metadata only.

Diagnostics must not enable blocking.

Diagnostics must not upload traffic.

Diagnostics must not store full browsing history.

## Next Technical Step

Add a diagnostic patch that makes it clear whether the VPN loop is seeing DNS candidate packets at all.
