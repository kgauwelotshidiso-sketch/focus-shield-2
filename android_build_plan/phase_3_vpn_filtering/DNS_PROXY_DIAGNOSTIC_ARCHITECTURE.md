# DNS Proxy Diagnostic Architecture

## Current Problem

DNS route capture proved useful, but it broke internet access because packets were captured and not forwarded.

## Safe Architecture

The safer architecture is:

VPN DNS route capture
→ local DNS proxy
→ hostname parser
→ dry-run decision engine
→ upstream DNS forwarder
→ response returned to phone

## First Mode

dns_proxy_diagnostic_only

## First Mode Must Keep Blocking Disabled

- blockingEnabled: false

## Data Flow

1. Phone sends DNS query
2. VPN captures DNS query
3. Focus Shield proxy receives query
4. Parser extracts hostname
5. Blocklist checker makes dry-run decision only
6. DNS forwarder sends query to upstream DNS
7. Upstream DNS returns response
8. Focus Shield returns response to phone
9. Diagnostic counters update

## Upstream DNS Options

Primary:

- 1.1.1.1

Fallback:

- 8.8.8.8

## Privacy Rule

Only diagnostic counters and last test hostname should be shown.

Do not build full browsing history storage.

## Blocking Rule

Do not enable blocking until DNS proxy forwarding is stable.
