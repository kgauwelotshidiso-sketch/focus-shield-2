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
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private lateinit var blocklistStore: FocusShieldBlocklistStore
    private val dnsFilter = FocusShieldDnsFilter()

    override fun onCreate() {
        super.onCreate()
        blocklistStore = FocusShieldBlocklistStore(applicationContext)
        reloadBlocklist()
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

    private fun reloadBlocklist() {
        val domains = blocklistStore.loadDomains()

        dnsFilter.reload(domains)

        nativeBlockedDomainCount = dnsFilter.blockedDomainCount()
        dnsFilteringReady = dnsFilter.hasBlocklist()
    }

    fun shouldBlockDomainForTestOnly(hostname: String): Boolean {
        return dnsFilter.shouldBlock(hostname)
    }

    override fun onDestroy() {
        stopProtection()
        super.onDestroy()
    }
}
