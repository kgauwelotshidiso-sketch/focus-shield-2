package com.example.focus_shield_android

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor

class FocusShieldVpnService : VpnService() {
    companion object {
        const val ACTION_START = "focus_shield.action.START_PROTECTION"
        const val ACTION_STOP = "focus_shield.action.STOP_PROTECTION"

        var isRunning: Boolean = false
            private set
    }

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> stopProtection()
            else -> startProtection()
        }

        return START_STICKY
    }

    private fun startProtection() {
        if (vpnInterface != null) {
            isRunning = true
            return
        }

        val builder = Builder()
            .setSession("Focus Shield")
            .addAddress("10.8.0.2", 32)
            .addDnsServer("1.1.1.1")

        vpnInterface = builder.establish()
        isRunning = vpnInterface != null
    }

    private fun stopProtection() {
        vpnInterface?.close()
        vpnInterface = null
        isRunning = false
        stopSelf()
    }

    override fun onDestroy() {
        stopProtection()
        super.onDestroy()
    }
}
