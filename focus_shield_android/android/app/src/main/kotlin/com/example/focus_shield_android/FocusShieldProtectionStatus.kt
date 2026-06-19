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
    val packetsObserved: Long,
    val dnsParserPrepared: Boolean,
    val dnsQueriesParsed: Long,
    val lastParsedHostname: String,
    val dryRunModeReady: Boolean,
    val dryRunBlocksDetected: Long,
    val lastDryRunDecision: String,
    val liveTrafficReadEnabled: Boolean,
    val blockingEnabled: Boolean,
    val liveObservationToggleAvailable: Boolean,
    val liveObservationRequested: Boolean,
    val liveObservationSafetyGate: String,
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
            "dnsParserPrepared" to dnsParserPrepared,
            "dnsQueriesParsed" to dnsQueriesParsed,
            "lastParsedHostname" to lastParsedHostname,
            "dryRunModeReady" to dryRunModeReady,
            "dryRunBlocksDetected" to dryRunBlocksDetected,
            "lastDryRunDecision" to lastDryRunDecision,
            "liveTrafficReadEnabled" to liveTrafficReadEnabled,
            "blockingEnabled" to blockingEnabled,
            "liveObservationToggleAvailable" to liveObservationToggleAvailable,
            "liveObservationRequested" to liveObservationRequested,
            "liveObservationSafetyGate" to liveObservationSafetyGate,
            "statusMessage" to statusMessage,
            "blocklistError" to blocklistError
        )
    }

    companion object {
        const val CURRENT_VERSION = 2

        fun build(blocklistStatus: FocusShieldBlocklistStatus): FocusShieldProtectionStatus {
            return FocusShieldProtectionStatus(
                nativeStatusVersion = CURRENT_VERSION,
                protectionMode = FocusShieldVpnService.protectionMode,
                vpnActive = FocusShieldVpnService.isRunning,
                blocklistLoaded = blocklistStatus.loaded,
                blockedDomainCount = blocklistStatus.count,
                nativeDnsReady = FocusShieldVpnService.dnsFilteringReady,
                nativeLoadedDomainCount = FocusShieldVpnService.nativeBlockedDomainCount,
                packetLoopPrepared = FocusShieldVpnService.packetLoopPrepared,
                packetLoopRunning = FocusShieldVpnService.packetLoopRunning,
                packetsObserved = FocusShieldVpnService.packetsObserved,
                dnsParserPrepared = FocusShieldVpnService.dnsParserPrepared,
                dnsQueriesParsed = FocusShieldVpnService.dnsQueriesParsed,
                lastParsedHostname = FocusShieldVpnService.lastParsedHostname,
                dryRunModeReady = FocusShieldVpnService.dryRunModeReady,
                dryRunBlocksDetected = FocusShieldVpnService.dryRunBlocksDetected,
                lastDryRunDecision = FocusShieldVpnService.lastDryRunDecision,
                liveTrafficReadEnabled = FocusShieldVpnService.liveTrafficReadEnabled,
                blockingEnabled = FocusShieldVpnService.blockingEnabled,
                liveObservationToggleAvailable =
                    FocusShieldVpnService.liveObservationToggleAvailable,
                liveObservationRequested = FocusShieldVpnService.liveObservationRequested,
                liveObservationSafetyGate = FocusShieldVpnService.liveObservationSafetyGate,
                statusMessage = FocusShieldVpnService.statusMessage,
                blocklistError = blocklistStatus.error ?: ""
            )
        }
    }
}
