# VPN Route Coverage Findings

## Current State

Focus Shield can activate a VPN shell and observe packets.

The observed packets are currently IPv6 control packets.

## Confirmed Working

- VPN permission flow
- VPN shell activation
- Live observation code gate
- Live observation-only mode
- Packet counter
- IPv6 packet counter
- Stop command
- Safe shutdown
- Blocking disabled state

## Not Yet Confirmed

- Normal app/browser TCP traffic observation
- Normal app/browser UDP traffic observation
- DNS candidate detection
- DNS query parsing from live traffic
- Dry-run would-block decisions from live traffic

## Diagnostic Direction

The next patch should add safer route coverage diagnostics, including:

- Whether IPv4 route coverage is configured
- Whether IPv6 route coverage is configured
- Whether DNS server is configured
- Whether route coverage mode is diagnostic-only
- Whether full traffic capture is attempted
- Whether blocking remains disabled

## Safety Rule

Route coverage diagnostics may widen observation only for testing.

Blocking must remain disabled.
