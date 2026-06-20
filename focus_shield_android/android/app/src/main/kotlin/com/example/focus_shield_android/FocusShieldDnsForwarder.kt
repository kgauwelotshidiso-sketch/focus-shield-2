package com.example.focus_shield_android

import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress

class FocusShieldDnsForwarder {
    private val upstreamPrimaryValue: String = "1.1.1.1"
    private val upstreamFallbackValue: String = "8.8.8.8"

    var prepared: Boolean = true
        private set

    var forwardingEnabled: Boolean = false
        private set

    var mode: String = "dns_forwarder_diagnostic_only"
        private set

    var forwardAttempts: Long = 0
        private set

    var forwardSuccesses: Long = 0
        private set

    var forwardFailures: Long = 0
        private set

    var lastDecision: String = "dns_forwarder_diagnostic_ready_no_routing"
        private set

    var lastError: String = ""
        private set

    fun prepareSkeletonOnly() {
        prepared = true
        forwardingEnabled = false
        mode = "dns_forwarder_diagnostic_only"
        lastDecision = "dns_forwarder_diagnostic_ready_no_routing"
        lastError = ""
    }

    fun describe(): String {
        return if (forwardingEnabled) {
            "dns_forwarder_enabled"
        } else {
            "dns_forwarder_diagnostic_ready_no_routing"
        }
    }

    fun runSafeDiagnosticQuery(): Boolean {
        prepared = true
        forwardingEnabled = false
        mode = "dns_forwarder_diagnostic_only"
        forwardAttempts += 1

        return try {
            val query = buildDnsQuery("example.com")
            val response = forwardToUpstream(query, upstreamPrimaryValue)

            if (response.isNotEmpty()) {
                forwardSuccesses += 1
                lastDecision = "diagnostic_forward_success:example.com"
                lastError = ""
                true
            } else {
                forwardFailures += 1
                lastDecision = "diagnostic_forward_empty_response"
                lastError = "empty_dns_response"
                false
            }
        } catch (primaryError: Exception) {
            try {
                val query = buildDnsQuery("example.com")
                val response = forwardToUpstream(query, upstreamFallbackValue)

                if (response.isNotEmpty()) {
                    forwardSuccesses += 1
                    lastDecision = "diagnostic_forward_success_fallback:example.com"
                    lastError = ""
                    true
                } else {
                    forwardFailures += 1
                    lastDecision = "diagnostic_forward_empty_fallback_response"
                    lastError = "empty_dns_fallback_response"
                    false
                }
            } catch (fallbackError: Exception) {
                forwardFailures += 1
                lastDecision = "diagnostic_forward_failed"
                lastError = fallbackError.message ?: "unknown_dns_forward_error"
                false
            }
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

    private fun forwardToUpstream(query: ByteArray, upstream: String): ByteArray {
        DatagramSocket().use { socket ->
            socket.soTimeout = 3000

            val address = InetAddress.getByName(upstream)
            val request = DatagramPacket(query, query.size, address, 53)

            socket.send(request)

            val buffer = ByteArray(512)
            val response = DatagramPacket(buffer, buffer.size)

            socket.receive(response)

            return buffer.copyOf(response.length)
        }
    }

    private fun buildDnsQuery(hostname: String): ByteArray {
        val output = ArrayList<Byte>()

        output.add(0x12)
        output.add(0x34)
        output.add(0x01)
        output.add(0x00)
        output.add(0x00)
        output.add(0x01)
        output.add(0x00)
        output.add(0x00)
        output.add(0x00)
        output.add(0x00)
        output.add(0x00)
        output.add(0x00)

        hostname.split(".").forEach { label ->
            output.add(label.length.toByte())
            label.encodeToByteArray().forEach { output.add(it) }
        }

        output.add(0x00)
        output.add(0x00)
        output.add(0x01)
        output.add(0x00)
        output.add(0x01)

        return output.toByteArray()
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
