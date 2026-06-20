package com.example.focus_shield_android

class FocusShieldDnsForwarder {
    private val upstreamPrimaryValue: String = "1.1.1.1"
    private val upstreamFallbackValue: String = "8.8.8.8"

    var prepared: Boolean = true
        private set

    var forwardingEnabled: Boolean = false
        private set

    var mode: String = "dns_forwarder_skeleton_only"
        private set

    var forwardAttempts: Long = 0
        private set

    var forwardSuccesses: Long = 0
        private set

    var forwardFailures: Long = 0
        private set

    var lastDecision: String = "dns_forwarder_skeleton_prepared_no_network_forwarding"
        private set

    var lastError: String = ""
        private set

    fun prepareSkeletonOnly() {
        prepared = true
        forwardingEnabled = false
        mode = "dns_forwarder_skeleton_only"
        lastDecision = "dns_forwarder_skeleton_prepared_no_network_forwarding"
        lastError = ""
    }

    fun describe(): String {
        return if (forwardingEnabled) {
            "dns_forwarder_enabled"
        } else {
            "dns_forwarder_skeleton_ready_forwarding_disabled"
        }
    }

    fun forwardDiagnosticDisabled(query: ByteArray): ByteArray? {
        prepared = true
        forwardingEnabled = false
        forwardAttempts += 1
        forwardFailures += 1
        lastDecision = "forwarding_blocked_by_safety_gate"
        lastError = "dns_forwarding_not_enabled_yet"
        return null
    }

    fun snapshot(): FocusShieldDnsForwarderStatus {
        return FocusShieldDnsForwarderStatus(
            dnsForwarderPrepared = prepared,
            dnsForwarderEnabled = forwardingEnabled,
            dnsForwarderMode = mode,
            upstreamPrimary = upstreamPrimaryValue,
            upstreamFallback = upstreamFallbackValue,
            forwardAttempts = forwardAttempts,
            forwardSuccesses = forwardSuccesses,
            forwardFailures = forwardFailures,
            lastForwarderDecision = lastDecision,
            lastForwarderError = lastError
        )
    }
}
