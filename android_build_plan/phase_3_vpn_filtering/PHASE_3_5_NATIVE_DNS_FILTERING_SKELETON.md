# Phase 3.5 — Native DNS Filtering Skeleton

## Status

Complete.

## Added

- FocusShieldDnsFilter.kt
- Native domain normalization
- Native should-block matching
- Subdomain matching
- VPN service blocklist reload action
- Native DNS readiness fields
- Native loaded domain count fields

## What This Phase Does

This phase prepares the native Android filtering logic.

The filter can now answer:

- should this domain be blocked?
- how many domains are loaded?
- is the native DNS filter ready?

## What This Phase Does Not Do Yet

This phase does not yet parse live DNS packets from the VPN interface.

That comes later.

## Matching Rule

A domain is blocked when:

- it exactly matches a saved blocked domain, or
- it is a subdomain of a saved blocked domain.

Example:

blocked-example.com blocks:

- blocked-example.com
- sub.blocked-example.com

## Next Phase

Phase 3.6 — Native VPN Packet Loop Preparation
