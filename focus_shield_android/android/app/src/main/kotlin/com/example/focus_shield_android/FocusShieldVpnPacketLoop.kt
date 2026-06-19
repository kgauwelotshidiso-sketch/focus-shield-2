package com.example.focus_shield_android

import android.os.ParcelFileDescriptor
import java.io.FileInputStream

class FocusShieldVpnPacketLoop {
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
    var packetsObserved: Long = 0
        private set

    private var workerThread: Thread? = null

    fun prepare() {
        prepared = true
    }

    fun start(
        vpnInterface: ParcelFileDescriptor?,
        liveReadEnabled: Boolean = false
    ) {
        prepared = true

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
                        packetsObserved += 1
                    }
                }
            }
        } catch (_: Exception) {
            running = false
        }
    }

    fun stop() {
        running = false
        workerThread?.interrupt()
        workerThread = null
    }
}
