package com.example.focus_shield_android

object FocusShieldDnsProxy {
    fun attachVpnService(service: android.net.VpnService?) {
        FocusShieldDnsForwarder.attachVpnService(service)
    }

    private val forwarder = FocusShieldDnsForwarder()

    var prepared: Boolean = true
        private set

    var running: Boolean = false
        private set

    var mode: FocusShieldDnsProxyMode = FocusShieldDnsProxyMode.DISABLED
        private set

    var queriesReceived: Long = 0
        private set

    var queriesForwarded: Long = 0
        private set

    var responsesReturned: Long = 0
        private set

    var errors: Long = 0
        private set

    var lastHost: String = ""
        private set

    var lastDecision: String = "dns_proxy_skeleton_ready_routing_disabled"
        private set

    var lastError: String = ""
        private set

    fun prepareDiagnosticOnly() {
        prepared = true
        running = false
        mode = FocusShieldDnsProxyMode.DNS_PROXY_DIAGNOSTIC_ONLY
        forwarder.prepareSkeletonOnly()
        lastDecision = "dns_proxy_diagnostic_skeleton_prepared_no_routing"
        lastError = ""
    }

    fun startDiagnosticOnlyWithoutRouting() {
        prepared = true
        running = false
        mode = FocusShieldDnsProxyMode.DNS_PROXY_DIAGNOSTIC_ONLY
        forwarder.prepareSkeletonOnly()
        lastDecision = forwarder.describe()
        lastError = ""
    }

    fun stop() {
        running = false

        if (mode == FocusShieldDnsProxyMode.DNS_PROXY_DIAGNOSTIC_ONLY) {
            lastDecision = "dns_proxy_stopped_safely"
        }
    }

    fun runForwarderDiagnostic(): Boolean {
        return forwarder.runSafeDiagnosticQuery()
    }

    fun forwarderSnapshot(): FocusShieldDnsForwarderStatus {
        return forwarder.snapshot()
    }

    fun snapshot(): FocusShieldDnsProxyStatus {
        return FocusShieldDnsProxyStatus(
            dnsProxyPrepared = prepared,
            dnsProxyRunning = running,
            dnsProxyMode = mode.label,
            dnsProxyQueriesReceived = queriesReceived,
            dnsProxyQueriesForwarded = queriesForwarded,
            dnsProxyResponsesReturned = responsesReturned,
            dnsProxyErrors = errors,
            lastDnsProxyHost = lastHost,
            lastDnsProxyDecision = lastDecision,
            lastDnsProxyError = lastError
        )
    }
}
