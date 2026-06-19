package com.example.focus_shield_android

import android.os.ParcelFileDescriptor
import java.io.FileInputStream

class FocusShieldVpnPacketLoop(
    private val dnsPacketParser: FocusShieldDnsPacketParser,
    private val dnsFilter: FocusShieldDnsFilter
) {
    companion object {
        private const val MAX_PACKET_SIZE = 32767
    }

    @Volatile
    var prepared: Boolean = false
        private set

    @Volatile
    var running: Boolean = false
        private set

    @Volatile
    var dryRunModeReady: Boolean = false
        private set

    @Volatile
    var packetsObserved: Long = 0
        private set

    @Volatile
    var dryRunBlocksDetected: Long = 0
        private set

    @Volatile
    var lastDryRunDecision: String = ""
        private set

    private var workerThread: Thread? = null

    fun prepare() {
        prepared = true
        dryRunModeReady = true
    }

    fun start(
        vpnInterface: ParcelFileDescriptor?,
        liveReadEnabled: Boolean = false,
        dryRunModeEnabled: Boolean = true
    ) {
        prepared = true
        dryRunModeReady = dryRunModeEnabled

        if (!liveReadEnabled) {
            running = false
            return
        }

        if (vpnInterface == null || running) {
            return
        }

        running = true

        workerThread = Thread {
            readPacketLoop(vpnInterface)
        }.apply {
            name = "FocusShieldVpnPacketLoop"
            isDaemon = true
            start()
        }
    }

    private fun readPacketLoop(vpnInterface: ParcelFileDescriptor) {
        val packet = ByteArray(MAX_PACKET_SIZE)

        try {
            FileInputStream(vpnInterface.fileDescriptor).use { input ->
                while (running && !Thread.currentThread().isInterrupted) {
                    val length = input.read(packet)

                    if (length > 0) {
                        handlePacket(packet, length)
                    }
                }
            }
        } catch (_: Exception) {
            running = false
        }
    }

    private fun handlePacket(packet: ByteArray, length: Int) {
        packetsObserved += 1

        if (!dryRunModeReady) {
            return
        }

        val result = dnsPacketParser.parseQueryHostname(packet, length)
        val hostname = result.hostname

        if (!result.validDnsQuery || hostname.isNullOrBlank()) {
            return
        }

        val wouldBlock = dnsFilter.shouldBlock(hostname)

        if (wouldBlock) {
            dryRunBlocksDetected += 1
        }

        lastDryRunDecision = if (wouldBlock) {
            "would_block:$hostname"
        } else {
            "would_allow:$hostname"
        }
    }

    fun stop() {
        running = false
        workerThread?.interrupt()
        workerThread = null
    }
}
