package com.example.focus_shield_android

object FocusShieldDnsProxy {

    fun forwarderSnapshot(): FocusShieldDnsForwarderStatus {
        return FocusShieldDnsForwarder.snapshot()
    }

    private var dnsProxyPrepared: Boolean = true
    private var dnsProxyRunning: Boolean = false
    private var dnsProxyMode: String = "disabled"
    private var dnsProxyQueriesReceived: Int = 0
    private var dnsProxyQueriesForwarded: Int = 0
    private var dnsProxyResponsesReturned: Int = 0
    private var dnsProxyErrors: Int = 0
    private var lastDnsProxyHost: String = "-"
    private var lastDnsProxyDecision: String = "dns_proxy_skeleton_ready_routing_disabled"
    private var lastDnsProxyError: String = "-"

    fun attachVpnService(service: android.net.VpnService?) {
        FocusShieldDnsForwarder.attachVpnService(service)
        lastDnsProxyDecision = if (service == null) {
            "dns_proxy_vpn_service_detached"
        } else {
            "dns_proxy_vpn_service_attached"
        }
    }

    fun prepareSkeletonOnly(): FocusShieldDnsProxyStatus {
        dnsProxyPrepared = true
        dnsProxyRunning = false
        dnsProxyMode = "disabled"
        lastDnsProxyDecision = "dns_proxy_skeleton_ready_routing_disabled"
        FocusShieldDnsForwarder.prepareSkeletonOnly()
        return snapshot()
    }

    fun runForwarderDiagnostic(): Boolean {
        val success = FocusShieldDnsForwarder.runSafeDiagnosticQuery()
        lastDnsProxyDecision = if (success) {
            "dns_proxy_forwarder_diagnostic_success"
        } else {
            "dns_proxy_forwarder_diagnostic_failed"
        }
        return success
    }

    fun describe(): String = lastDnsProxyDecision

    fun snapshot(): FocusShieldDnsProxyStatus {
        return FocusShieldDnsProxyStatus(
            dnsProxyPrepared = dnsProxyPrepared,
            dnsProxyRunning = dnsProxyRunning,
            dnsProxyMode = dnsProxyMode,
            dnsProxyQueriesReceived = dnsProxyQueriesReceived,
            dnsProxyQueriesForwarded = dnsProxyQueriesForwarded,
            dnsProxyResponsesReturned = dnsProxyResponsesReturned,
            dnsProxyErrors = dnsProxyErrors,
            lastDnsProxyHost = lastDnsProxyHost,
            lastDnsProxyDecision = lastDnsProxyDecision,
            lastDnsProxyError = lastDnsProxyError,
        )
    }

    fun isPrepared(): Boolean = dnsProxyPrepared
    fun isRunning(): Boolean = dnsProxyRunning
    fun getMode(): String = dnsProxyMode
    fun getQueriesReceived(): Int = dnsProxyQueriesReceived
    fun getQueriesForwarded(): Int = dnsProxyQueriesForwarded
    fun getResponsesReturned(): Int = dnsProxyResponsesReturned
    fun getErrors(): Int = dnsProxyErrors
    fun getLastHost(): String = lastDnsProxyHost
    fun getLastDecision(): String = lastDnsProxyDecision
    fun getLastError(): String = lastDnsProxyError
}
