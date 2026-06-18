package com.focusshield.nativevpn

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Bundle

/**
 * VpnPermissionActivity
 *
 * Starter skeleton only.
 *
 * Future responsibility:
 * - Ask Android for VPN permission
 * - Return result to Flutter
 */
class VpnPermissionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent: Intent? = VpnService.prepare(this)

        if (intent != null) {
            // TODO Phase 4:
            // Start permission request using Activity Result API in real project.
            startActivityForResult(intent, VPN_PERMISSION_REQUEST_CODE)
        } else {
            // Permission already granted.
            finish()
        }
    }

    companion object {
        const val VPN_PERMISSION_REQUEST_CODE = 3001
    }
}
