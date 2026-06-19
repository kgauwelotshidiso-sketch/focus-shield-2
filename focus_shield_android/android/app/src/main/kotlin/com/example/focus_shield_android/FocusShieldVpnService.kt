package com.example.focus_shield_android

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor

class FocusShieldVpnService : VpnService() {
    companion object {
        const val ACTION_START = "focus_shield.action.START_PROTECTION"
        const val ACTION_STOP = "focus_shield.action.STOP_PROTECTION"
        const val ACTION_RELOAD_BLOCKLIST = "focus_shield.action.RELOAD_BLOCKLIST"

        var isRunning: Boolean = false
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

        var dnsParserPrepared: Boolean = false
            private set

        var dnsQueriesParsed: Long = 0
            private set

        var lastParsedHostname: String = ""
            private set
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private lateinit var blocklistStore: FocusShieldBlocklistStore
    private val dnsFilter = FocusShieldDnsFilter()
    private val dnsPacketParser = FocusShieldDnsPacketParser()
    private val packetLoop = FocusShieldVpnPacketLoop()

    override fun onCreate() {
        super.onCreate()
        blocklistStore = FocusShieldBlocklistStore(applicationContext)
        packetLoop.prepare()
        reloadBlocklist()
        updateNativeStatus()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> stopProtection()
            ACTION_RELOAD_BLOCKLIST -> reloadBlocklist()
            else -> startProtection()
        }

        return START_STICKY
    }

    private fun startProtection() {
        reloadBlocklist()

        if (vpnInterface != null) {
            isRunning = true
            packetLoop.start(vpnInterface, liveReadEnabled = false)
            updateNativeStatus()
            return
        }

        val builder = Builder()
            .setSession("Focus Shield")
            .addAddress("10.8.0.2", 32)
            .addDnsServer("1.1.1.1")

        vpnInterface = builder.establish()
        isRunning = vpnInterface != null

        packetLoop.start(vpnInterface, liveReadEnabled = false)
        updateNativeStatus()
    }

    private fun stopProtection() {
        packetLoop.stop()
        updateNativeStatus()

        vpnInterface?.close()
        vpnInterface = null
        isRunning = false
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
        updateNativeStatus()
    }

    private fun updateNativeStatus() {
        packetLoopPrepared = packetLoop.prepared
        packetLoopRunning = packetLoop.running
        packetsObserved = packetLoop.packetsObserved

        dnsParserPrepared = dnsPacketParser.prepared
        dnsQueriesParsed = dnsPacketParser.parsedQueries
        lastParsedHostname = dnsPacketParser.lastHostname
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
        stopProtection()
        super.onDestroy()
    }
}
