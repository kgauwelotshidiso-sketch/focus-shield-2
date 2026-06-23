package com.example.focus_shield_android

data class FocusShieldProtectionStatus(
    val nativeStatusVersion: Int,
    val protectionMode: String,
    val vpnActive: Boolean,
    val blocklistLoaded: Boolean,
    val blockedDomainCount: Int,
    val nativeDnsReady: Boolean,
    val nativeLoadedDomainCount: Int,
    val packetLoopPrepared: Boolean,
    val packetLoopRunning: Boolean,
    val packetsObserved: Int,
    val ipPacketsObserved: Int,
    val ipv6PacketsObserved: Int,
    val udpPacketsObserved: Int,
    val ipv6UdpPacketsObserved: Int,
    val tcpPacketsObserved: Int,
    val ipv6TcpPacketsObserved: Int,
    val dnsCandidatePacketsObserved: Int,
    val ipv6DnsCandidatePacketsObserved: Int,
    val dnsParseAttempts: Int,
    val dnsParseFailures: Int,
    val lastPacketProtocol: String,
    val lastParserError: String,
    val lastPacketSummary: String,
    val dnsParserPrepared: Boolean,
    val dnsQueriesParsed: Int,
    val lastParsedHostname: String,
    val dryRunModeReady: Boolean,
    val dryRunBlocksDetected: Int,
    val lastDryRunDecision: String,
    val dnsProxyPrepared: Boolean,
    val dnsProxyRunning: Boolean,
    val dnsProxyMode: String,
    val dnsProxyQueriesReceived: Int,
    val dnsProxyQueriesForwarded: Int,
    val dnsProxyResponsesReturned: Int,
    val dnsProxyErrors: Int,
    val lastDnsProxyHost: String,
    val lastDnsProxyDecision: String,
    val lastDnsProxyError: String,
    val dnsForwarderPrepared: Boolean,
    val dnsForwarderEnabled: Boolean,
    val dnsForwarderMode: String,
    val upstreamPrimary: String,
    val upstreamFallback: String,
    val forwardAttempts: Int,
    val forwardSuccesses: Int,
    val forwardFailures: Int,
    val lastForwarderDecision: String,
    val lastForwarderError: String,
    val liveTrafficReadEnabled: Boolean,
    val blockingEnabled: Boolean,
    val liveObservationToggleAvailable: Boolean,
    val liveObservationRequested: Boolean,
    val liveObservationGateVersion: Int,
    val liveObservationCodeGateReady: Boolean,
    val liveObservationCodeGateUnlocked: Boolean,
    val liveObservationSafetyGate: String,
    val liveObservationUnlockAttempts: Int,
    val statusMessage: String,
    val blocklistError: String
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "nativeStatusVersion" to nativeStatusVersion,
            "protectionMode" to protectionMode,
            "vpnActive" to vpnActive,
            "blocklistLoaded" to blocklistLoaded,
            "blockedDomainCount" to blockedDomainCount,
            "nativeDnsReady" to nativeDnsReady,
            "nativeLoadedDomainCount" to nativeLoadedDomainCount,
            "packetLoopPrepared" to packetLoopPrepared,
            "packetLoopRunning" to packetLoopRunning,
            "packetsObserved" to packetsObserved,
            "ipPacketsObserved" to ipPacketsObserved,
            "ipv6PacketsObserved" to ipv6PacketsObserved,
            "udpPacketsObserved" to udpPacketsObserved,
            "ipv6UdpPacketsObserved" to ipv6UdpPacketsObserved,
            "tcpPacketsObserved" to tcpPacketsObserved,
            "ipv6TcpPacketsObserved" to ipv6TcpPacketsObserved,
            "dnsCandidatePacketsObserved" to dnsCandidatePacketsObserved,
            "ipv6DnsCandidatePacketsObserved" to ipv6DnsCandidatePacketsObserved,
            "dnsParseAttempts" to dnsParseAttempts,
            "dnsParseFailures" to dnsParseFailures,
            "lastPacketProtocol" to lastPacketProtocol,
            "lastParserError" to lastParserError,
            "lastPacketSummary" to lastPacketSummary,
            "dnsParserPrepared" to dnsParserPrepared,
            "dnsQueriesParsed" to dnsQueriesParsed,
            "lastParsedHostname" to lastParsedHostname,
            "dryRunModeReady" to dryRunModeReady,
            "dryRunBlocksDetected" to dryRunBlocksDetected,
            "lastDryRunDecision" to lastDryRunDecision,
            "dnsProxyPrepared" to dnsProxyPrepared,
            "dnsProxyRunning" to dnsProxyRunning,
            "dnsProxyMode" to dnsProxyMode,
            "dnsProxyQueriesReceived" to dnsProxyQueriesReceived,
            "dnsProxyQueriesForwarded" to dnsProxyQueriesForwarded,
            "dnsProxyResponsesReturned" to dnsProxyResponsesReturned,
            "dnsProxyErrors" to dnsProxyErrors,
            "lastDnsProxyHost" to lastDnsProxyHost,
            "lastDnsProxyDecision" to lastDnsProxyDecision,
            "lastDnsProxyError" to lastDnsProxyError,
            "dnsForwarderPrepared" to dnsForwarderPrepared,
            "dnsForwarderEnabled" to dnsForwarderEnabled,
            "dnsForwarderMode" to dnsForwarderMode,
            "upstreamPrimary" to upstreamPrimary,
            "upstreamFallback" to upstreamFallback,
            "forwardAttempts" to forwardAttempts,
            "forwardSuccesses" to forwardSuccesses,
            "forwardFailures" to forwardFailures,
            "lastForwarderDecision" to lastForwarderDecision,
            "lastForwarderError" to lastForwarderError,
            "liveTrafficReadEnabled" to liveTrafficReadEnabled,
            "blockingEnabled" to blockingEnabled,
            "liveObservationToggleAvailable" to liveObservationToggleAvailable,
            "liveObservationRequested" to liveObservationRequested,
            "liveObservationGateVersion" to liveObservationGateVersion,
            "liveObservationCodeGateReady" to liveObservationCodeGateReady,
            "liveObservationCodeGateUnlocked" to liveObservationCodeGateUnlocked,
            "liveObservationSafetyGate" to liveObservationSafetyGate,
            "liveObservationUnlockAttempts" to liveObservationUnlockAttempts,
            "statusMessage" to statusMessage,
            "blocklistError" to blocklistError
        )
    }

    companion object {
        const val CURRENT_VERSION = 7

        fun build(blocklistStatus: FocusShieldBlocklistStatus): FocusShieldProtectionStatus {
            val dnsProxyStatus = FocusShieldDnsProxy.snapshot()
            val dnsForwarderStatus = FocusShieldDnsProxy.forwarderSnapshot()

            return FocusShieldProtectionStatus(
                nativeStatusVersion = (CURRENT_VERSION).focusShieldStatusInt(),
                protectionMode = (FocusShieldVpnService.protectionMode).focusShieldStatusString(),
                vpnActive = FocusShieldVpnService.isRunning,
                blocklistLoaded = blocklistStatus.loaded,
                blockedDomainCount = (blocklistStatus.count).focusShieldStatusInt(),
                nativeDnsReady = FocusShieldVpnService.dnsFilteringReady,
                nativeLoadedDomainCount = (FocusShieldVpnService.nativeBlockedDomainCount).focusShieldStatusInt(),
                packetLoopPrepared = (FocusShieldVpnService.packetLoopPrepared).toInt(),
                packetLoopRunning = (FocusShieldVpnService.packetLoopRunning).toInt(),
                packetsObserved = (FocusShieldVpnService.packetsObserved).focusShieldStatusInt(),
                ipPacketsObserved = (FocusShieldVpnService.ipPacketsObserved).focusShieldStatusInt(),
                ipv6PacketsObserved = (FocusShieldVpnService.ipv6PacketsObserved).focusShieldStatusInt(),
                udpPacketsObserved = (FocusShieldVpnService.udpPacketsObserved).focusShieldStatusInt(),
                ipv6UdpPacketsObserved = (FocusShieldVpnService.ipv6UdpPacketsObserved).focusShieldStatusInt(),
                tcpPacketsObserved = (FocusShieldVpnService.tcpPacketsObserved).focusShieldStatusInt(),
                ipv6TcpPacketsObserved = (FocusShieldVpnService.ipv6TcpPacketsObserved).focusShieldStatusInt(),
                dnsCandidatePacketsObserved =
                    FocusShieldVpnService.dnsCandidatePacketsObserved,
                ipv6DnsCandidatePacketsObserved =
                    FocusShieldVpnService.ipv6DnsCandidatePacketsObserved,
                dnsParseAttempts = (FocusShieldVpnService.dnsParseAttempts).focusShieldStatusInt(),
                dnsParseFailures = (FocusShieldVpnService.dnsParseFailures).focusShieldStatusInt(),
                lastPacketProtocol = (FocusShieldVpnService.lastPacketProtocol).focusShieldStatusString(),
                lastParserError = (FocusShieldVpnService.lastParserError).focusShieldStatusString(),
                lastPacketSummary = (FocusShieldVpnService.lastPacketSummary).focusShieldStatusString(),
                dnsParserPrepared = (FocusShieldVpnService.dnsParserPrepared).toInt(),
                dnsQueriesParsed = (FocusShieldVpnService.dnsQueriesParsed).focusShieldStatusInt(),
                lastParsedHostname = (FocusShieldVpnService.lastParsedHostname).focusShieldStatusString(),
                dryRunModeReady = FocusShieldVpnService.dryRunModeReady,
                dryRunBlocksDetected = (FocusShieldVpnService.dryRunBlocksDetected).focusShieldStatusInt(),
                lastDryRunDecision = (FocusShieldVpnService.lastDryRunDecision).focusShieldStatusString(),
                dnsProxyPrepared = dnsProxyStatus.dnsProxyPrepared,
                dnsProxyRunning = dnsProxyStatus.dnsProxyRunning,
                dnsProxyMode = (dnsProxyStatus.dnsProxyMode).focusShieldStatusString(),
                dnsProxyQueriesReceived = (dnsProxyStatus.dnsProxyQueriesReceived).focusShieldStatusInt(),
                dnsProxyQueriesForwarded = (dnsProxyStatus.dnsProxyQueriesForwarded).focusShieldStatusInt(),
                dnsProxyResponsesReturned = (dnsProxyStatus.dnsProxyResponsesReturned).focusShieldStatusInt(),
                dnsProxyErrors = (dnsProxyStatus.dnsProxyErrors).focusShieldStatusInt(),
                lastDnsProxyHost = (dnsProxyStatus.lastDnsProxyHost).focusShieldStatusString(),
                lastDnsProxyDecision = (dnsProxyStatus.lastDnsProxyDecision).focusShieldStatusString(),
                lastDnsProxyError = (dnsProxyStatus.lastDnsProxyError).focusShieldStatusString(),
                dnsForwarderPrepared = dnsForwarderStatus.dnsForwarderPrepared,
                dnsForwarderEnabled = dnsForwarderStatus.dnsForwarderEnabled,
                dnsForwarderMode = (dnsForwarderStatus.dnsForwarderMode).focusShieldStatusString(),
                upstreamPrimary = (dnsForwarderStatus.upstreamPrimary).focusShieldStatusString(),
                upstreamFallback = (dnsForwarderStatus.upstreamFallback).focusShieldStatusString(),
                forwardAttempts = (dnsForwarderStatus.forwardAttempts).focusShieldStatusInt(),
                forwardSuccesses = (dnsForwarderStatus.forwardSuccesses).focusShieldStatusInt(),
                forwardFailures = (dnsForwarderStatus.forwardFailures).focusShieldStatusInt(),
                lastForwarderDecision = (dnsForwarderStatus.lastForwarderDecision).focusShieldStatusString(),
                lastForwarderError = (dnsForwarderStatus.lastForwarderError).focusShieldStatusString(),
                liveTrafficReadEnabled = FocusShieldVpnService.liveTrafficReadEnabled,
                blockingEnabled = FocusShieldVpnService.blockingEnabled,
                liveObservationToggleAvailable =
                    FocusShieldVpnService.liveObservationToggleAvailable,
                liveObservationRequested = FocusShieldVpnService.liveObservationRequested,
                liveObservationGateVersion = (FocusShieldVpnService.liveObservationGateVersion).focusShieldStatusInt(),
                liveObservationCodeGateReady =
                    FocusShieldVpnService.liveObservationCodeGateReady,
                liveObservationCodeGateUnlocked =
                    FocusShieldVpnService.liveObservationCodeGateUnlocked,
                liveObservationSafetyGate = (FocusShieldVpnService.liveObservationSafetyGate).focusShieldStatusString(),
                liveObservationUnlockAttempts =
                    FocusShieldVpnService.liveObservationUnlockAttempts,
                statusMessage = (FocusShieldVpnService.statusMessage).focusShieldStatusString(),
                blocklistError = (blocklistStatus.error ?: "").focusShieldStatusString()
            )
        }
    }
}

private fun Any?.focusShieldStatusInt(): Int {
    return when (this) {
        is Int -> this
        is Long -> this.toInt()
        is Short -> this.toInt()
        is Byte -> this.toInt()
        is Double -> this.toInt()
        is Float -> this.toInt()
        is String -> this.toIntOrNull() ?: 0
        is Boolean -> if (this) 1 else 0
        else -> 0
    }
}

private fun Any?.focusShieldStatusLong(): Long {
    return when (this) {
        is Long -> this
        is Int -> this.toLong()
        is Short -> this.toLong()
        is Byte -> this.toLong()
        is Double -> this.toLong()
        is Float -> this.toLong()
        is String -> this.toLongOrNull() ?: 0L
        is Boolean -> if (this) 1L else 0L
        else -> 0L
    }
}

private fun Any?.focusShieldStatusString(): String {
    return this?.toString() ?: "-"
}

