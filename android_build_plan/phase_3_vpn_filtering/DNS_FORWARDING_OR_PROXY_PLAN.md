# DNS Forwarding or Proxy Plan

## Problem

DNS route capture breaks internet access because packets are captured but not forwarded.

## Safe Solution Direction

Build a local DNS proxy before re-enabling DNS route capture.

## First Proxy Mode

dns_proxy_diagnostic_only

## First Proxy Mode Must Do

- Receive DNS query packets
- Parse hostname
- Forward allowed query to upstream DNS
- Return upstream response
- Keep blocking disabled
- Record diagnostic counters

## First Proxy Mode Must Not Do

- Block domains
- Replace DNS responses
- Capture full traffic
- Upload query data
- Store full browsing history
- Run hidden enforcement

## Upstream DNS Candidates

- 1.1.1.1
- 8.8.8.8

## Required Before Blocking

- Internet works while VPN is active
- DNS proxy forwards queries successfully
- DNS parser remains stable
- Stop command restores normal phone connection
- Dry-run would-block decisions work with safe test domains

## Current Blocking Status

Disabled.
