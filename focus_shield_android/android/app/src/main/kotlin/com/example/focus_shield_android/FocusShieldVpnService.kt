package com.example.focus_shield_android

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor

class FocusShieldVpnService : VpnService() {
    companion object {
        const val ACTION_START = "focus_shield.action.START_PROTECTION"
        const val ACTION_STOP = "focus_shield.action.STOP_PROTECTION"
        const val ACTION_RELOAD_BLOCKLIST = "focus_shield.action.RELOAD_BLOCKLIST"
        const val ACTION_PREPARE_LIVE_OBSERVATION =
            "focus_shield.action.PREPARE_LIVE_OBSERVATION"
        const val ACTION_DISABLE_LIVE_OBSERVATION =
            "focus_shield.action.DISABLE_LIVE_OBSERVATION"
        const val ACTION_REQUEST_LIVE_OBSERVATION_UNLOCK =
            "focus_shield.action.REQUEST_LIVE_OBSERVATION_UNLOCK"

        var isRunning: Boolean = false
            private set

        var protectionMode: String = "dry_run_prepared"
            private set

        var liveTrafficReadEnabled: Boolean = false
            private set

        var blockingEnabled: Boolean = false
            private set

        var liveObservationToggleAvailable: Boolean = true
            private set

        var liveObservationRequested: Boolean = false
            private set

        var liveObservationGateVersion: Int = FocusShieldLiveObservationGate.gateVersion
            private set

        var liveObservationCodeGateReady: Boolean = true
            private set

        var liveObservationCodeGateUnlocked: Boolean =
            FocusShieldLiveObservationGate.canEnableLiveObservation()
            private set

        var liveObservationSafetyGate: String =
            FocusShieldLiveObservationGate.gateStatus()
            private set

        var liveObservationUnlockAttempts: Int = 0
            private set

        var statusMessage: String =
            "Dry-run protection is prepared. Live traffic reading is disabled."
            private set

        var dnsFilteringReady: Boolean = false
            private set

        var nativeBlockedDomainCount: Int = 0
            private set

        var packetLoopPrepared: Boolean = false
            private set

        var packetLoopRunning: Boolean = false
            private set

        var packetsObserved: Long = 0
            private set

        var ipPacketsObserved: Long = 0
            private set

        var ipv6PacketsObserved: Long = 0
            private set

        var udpPacketsObserved: Long = 0
            private set

        var ipv6UdpPacketsObserved: Long = 0
            private set

        var tcpPacketsObserved: Long = 0
            private set

        var ipv6TcpPacketsObserved: Long = 0
            private set

        var dnsCandidatePacketsObserved: Long = 0
            private set

        var ipv6DnsCandidatePacketsObserved: Long = 0
            private set

        var dnsParseAttempts: Long = 0
            private set

        var dnsParseFailures: Long = 0
            private set

        var lastPacketProtocol: String = ""
            private set

        var lastParserError: String = ""
            private set

        var lastPacketSummary: String = ""
            private set

        var dnsParserPrepared: Boolean = false
            private set

        var dnsQueriesParsed: Long = 0
            private set

        var lastParsedHostname: String = ""
            private set

        var dryRunModeReady: Boolean = false
            private set

        var dryRunBlocksDetected: Long = 0
            private set

        var lastDryRunDecision: String = ""
            private set
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private lateinit var blocklistStore: FocusShieldBlocklistStore
    private val dnsFilter = FocusShieldDnsFilter()
    private val dnsPacketParser = FocusShieldDnsPacketParser()
    private val packetLoop = FocusShieldVpnPacketLoop(
        dnsPacketParser = dnsPacketParser,
        dnsFilter = dnsFilter
    )

    override fun onCreate() {
        FocusShieldDnsProxy.attachVpnService(this)
        super.onCreate()
        blocklistStore = FocusShieldBlocklistStore(applicationContext)
        FocusShieldDnsProxy.prepareDiagnosticOnly()
        protectionMode = "dry_run_prepared"
        liveTrafficReadEnabled = false
        blockingEnabled = false
        liveObservationToggleAvailable = true
        liveObservationRequested = false
        syncLiveObservationGate()
        packetLoop.prepare()
        reloadBlocklist()
        statusMessage =
            "Native protection is prepared in dry-run mode. Live traffic reading is disabled."
        updateNativeStatus()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> stopProtection()
            ACTION_RELOAD_BLOCKLIST -> reloadBlocklist()
            ACTION_PREPARE_LIVE_OBSERVATION -> prepareLiveObservation()
            ACTION_DISABLE_LIVE_OBSERVATION -> disableLiveObservation()
            ACTION_REQUEST_LIVE_OBSERVATION_UNLOCK -> requestLiveObservationUnlock()
            else -> startProtection()
        }

        return START_STICKY
    }

    private fun startProtection() {
        protectionMode = if (liveObservationRequested) {
            "observation_prepared_locked"
        } else {
            "dry_run_prepared"
        }

        liveTrafficReadEnabled = false
        blockingEnabled = false

        reloadBlocklist()

        if (vpnInterface != null) {
            isRunning = true
            packetLoop.start(
                vpnInterface = vpnInterface,
                liveReadEnabled = false,
                dryRunModeEnabled = true
            )
            statusMessage =
                "VPN shell is active without DNS route capture. Live traffic reading is disabled."
            updateNativeStatus()
            return
        }

        val builder = Builder()
            .setSession("Focus Shield")
            .addAddress("10.8.0.2", 32)
            .addDnsServer("1.1.1.1")
            .addDnsServer("8.8.8.8")

        try {
            builder.addAddress("fd00:7:7:7::2", 128)
            builder.addDnsServer("2606:4700:4700::1111")
            builder.addDnsServer("2001:4860:4860::8888")
        } catch (_: Exception) {
            // Some Android/network combinations may reject IPv6 tunnel setup.
            // Route capture stays disabled until forwarding is implemented.
        }

        // IMPORTANT:
        // Do not add DNS routes here until packet forwarding or DNS proxying exists.
        // Phase 3.45 proved DNS route capture works, but it breaks internet access
        // because captured packets are not forwarded yet.

        vpnInterface = builder.establish()
        isRunning = vpnInterface != null

        packetLoop.start(
            vpnInterface = vpnInterface,
            liveReadEnabled = false,
            dryRunModeEnabled = true
        )

        statusMessage = if (isRunning) {
            "VPN shell started without DNS route capture. Live traffic reading is disabled."
        } else {
            "VPN shell could not start. Android permission may still be required."
        }

        updateNativeStatus()
    }

    private fun prepareLiveObservation() {
        liveObservationToggleAvailable = true
        liveObservationRequested = true
        syncLiveObservationGate()

        if (FocusShieldLiveObservationGate.canEnableLiveObservation()) {
            protectionMode = FocusShieldLiveObservationGate.allowedProtectionModeWhenUnlocked
            liveTrafficReadEnabled = true
            blockingEnabled = false
            statusMessage =
                "Live observation only is enabled by code gate. Blocking remains disabled."
        } else {
            liveTrafficReadEnabled = false
            blockingEnabled = false
            protectionMode = "observation_prepared_locked"
            statusMessage =
                "Live observation was requested, but the safety gate is locked. Live traffic reading remains disabled."
        }

        packetLoop.start(
            vpnInterface = vpnInterface,
            liveReadEnabled = liveTrafficReadEnabled,
            dryRunModeEnabled = true
        )

        updateNativeStatus()
    }

    private fun requestLiveObservationUnlock() {
        liveObservationUnlockAttempts += 1
        syncLiveObservationGate()

        if (FocusShieldLiveObservationGate.canEnableLiveObservation()) {
            liveTrafficReadEnabled = true
            blockingEnabled = false
            protectionMode = FocusShieldLiveObservationGate.allowedProtectionModeWhenUnlocked
            statusMessage =
                "Live observation code gate is unlocked for observation only. Blocking remains disabled."
        } else {
            liveTrafficReadEnabled = false
            blockingEnabled = false
            protectionMode = if (liveObservationRequested) {
                "observation_prepared_locked"
            } else {
                "dry_run_prepared"
            }
            statusMessage =
                "Live observation code gate remains locked. Live traffic reading and blocking remain disabled."
        }

        packetLoop.start(
            vpnInterface = vpnInterface,
            liveReadEnabled = liveTrafficReadEnabled,
            dryRunModeEnabled = true
        )

        updateNativeStatus()
    }

    private fun disableLiveObservation() {
        liveObservationRequested = false
        liveTrafficReadEnabled = false
        blockingEnabled = false
        syncLiveObservationGate()

        protectionMode = if (isRunning) {
            "dry_run_prepared"
        } else {
            "stopped"
        }

        statusMessage =
            "Live observation request cleared. Safe dry-run preparation remains available."

        packetLoop.start(
            vpnInterface = vpnInterface,
            liveReadEnabled = false,
            dryRunModeEnabled = true
        )

        FocusShieldDnsProxy.startDiagnosticOnlyWithoutRouting()
        updateNativeStatus()
    }

    private fun stopProtection() {
        packetLoop.stop()
        FocusShieldDnsProxy.stop()
        updateNativeStatus()

        vpnInterface?.close()
        vpnInterface = null
        isRunning = false
        liveTrafficReadEnabled = false
        blockingEnabled = false
        liveObservationRequested = false
        syncLiveObservationGate()
        protectionMode = "stopped"
        statusMessage = "Native protection is stopped."
        stopSelf()
    }

    private fun reloadBlocklist() {
        val domains = try {
            blocklistStore.loadDomains()
        } catch (_: Exception) {
            emptyList()
        }

        dnsFilter.reload(domains)

        nativeBlockedDomainCount = dnsFilter.blockedDomainCount()
        dnsFilteringReady = dnsFilter.hasBlocklist()
        syncLiveObservationGate()

        if (dnsFilteringReady) {
            statusMessage =
                "Blocklist loaded. Dry-run protection is prepared, but live traffic reading is disabled."
        } else {
            statusMessage =
                "No native blocked domains are loaded yet. Dry-run protection is waiting for blocklist data."
        }

        updateNativeStatus()
    }

    private fun syncLiveObservationGate() {
        liveObservationGateVersion = FocusShieldLiveObservationGate.gateVersion
        liveObservationCodeGateReady = true
        liveObservationCodeGateUnlocked =
            FocusShieldLiveObservationGate.canEnableLiveObservation()
        liveObservationSafetyGate = FocusShieldLiveObservationGate.gateStatus()
    }

    private fun updateNativeStatus() {
        syncLiveObservationGate()

        packetLoopPrepared = packetLoop.prepared
        packetLoopRunning = packetLoop.running
        packetsObserved = packetLoop.packetsObserved
        ipPacketsObserved = packetLoop.ipPacketsObserved
        ipv6PacketsObserved = packetLoop.ipv6PacketsObserved
        udpPacketsObserved = packetLoop.udpPacketsObserved
        ipv6UdpPacketsObserved = packetLoop.ipv6UdpPacketsObserved
        tcpPacketsObserved = packetLoop.tcpPacketsObserved
        ipv6TcpPacketsObserved = packetLoop.ipv6TcpPacketsObserved
        dnsCandidatePacketsObserved = packetLoop.dnsCandidatePacketsObserved
        ipv6DnsCandidatePacketsObserved =
            packetLoop.ipv6DnsCandidatePacketsObserved
        dnsParseAttempts = packetLoop.dnsParseAttempts
        dnsParseFailures = packetLoop.dnsParseFailures
        lastPacketProtocol = packetLoop.lastPacketProtocol
        lastParserError = if (packetLoop.lastParserError.isNotBlank()) {
            packetLoop.lastParserError
        } else {
            dnsPacketParser.lastParserError
        }
        lastPacketSummary = packetLoop.lastPacketSummary

        dnsParserPrepared = dnsPacketParser.prepared
        dnsQueriesParsed = dnsPacketParser.parsedQueries
        lastParsedHostname = dnsPacketParser.lastHostname

        dryRunModeReady = packetLoop.dryRunModeReady
        dryRunBlocksDetected = packetLoop.dryRunBlocksDetected
        lastDryRunDecision = packetLoop.lastDryRunDecision
    }

    fun shouldBlockDomainForTestOnly(hostname: String): Boolean {
        return dnsFilter.shouldBlock(hostname)
    }

    fun parseDnsPacketForTestOnly(packet: ByteArray, length: Int): FocusShieldDnsParseResult {
        val result = dnsPacketParser.parseQueryHostname(packet, length)
        updateNativeStatus()
        return result
    }

    override fun onDestroy() {
        FocusShieldDnsProxy.attachVpnService(null)
        stopProtection()
        super.onDestroy()
    }
}
