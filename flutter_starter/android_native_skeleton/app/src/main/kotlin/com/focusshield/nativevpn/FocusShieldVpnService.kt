package com.focusshield.nativevpn

import android.net.VpnService
import android.content.Intent
import android.os.ParcelFileDescriptor

/**
 * FocusShieldVpnService
 *
 * Starter skeleton only.
 * This file does not implement live VPN filtering yet.
 *
 * Future responsibility:
 * - Start Android local VPN tunnel
 * - Observe domain-level DNS metadata
 * - Ask DomainDecisionBridge whether to allow or block
 * - Never inspect private message content
 * - Never store full packets
 */
class FocusShieldVpnService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null
    private var isRunning: Boolean = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // TODO Phase 4:
        // 1. Confirm user permission is granted.
        // 2. Build VPN interface.
        // 3. Start lightweight DNS/domain filtering loop.
        // 4. Send domain decisions through DomainDecisionBridge.
        isRunning = true
        return START_STICKY
    }

    override fun onDestroy() {
        stopVpnSafely()
        super.onDestroy()
    }

    private fun stopVpnSafely() {
        try {
            vpnInterface?.close()
        } catch (_: Exception) {
            // Ignore close errors in starter skeleton.
        }

        vpnInterface = null
        isRunning = false
    }

    fun isVpnRunning(): Boolean {
        return isRunning
    }
}
