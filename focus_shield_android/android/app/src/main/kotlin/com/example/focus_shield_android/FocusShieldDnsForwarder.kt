package com.example.focus_shield_android

import android.net.VpnService
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress

object FocusShieldDnsForwarder {
    private var vpnService: VpnService? = null

    private const val upstreamPrimary: String = "1.1.1.1"
    private const val upstreamFallback: String = "8.8.8.8"

    private var forwardAttempts: Int = 0
    private var forwardSuccesses: Int = 0
    private var forwardFailures: Int = 0
    private var lastDecision: String = "dns_forwarder_diagnostic_ready_no_routing"
    private var lastError: String = "-"

    fun attachVpnService(service: VpnService?) {
        vpnService = service
        lastDecision = if (service == null) {
            "vpn_protect_hook_detached"
        } else {
            "vpn_protect_hook_attached"
        }
    }

    fun isPrepared(): Boolean = true
    fun isEnabled(): Boolean = false
    fun getMode(): String {
        return if (vpnService == null) {
            "dns_forwarder_diagnostic_only"
        } else {
            "dns_forwarder_diagnostic_only_vpn_protect_ready"
        }
    }

    fun getUpstreamPrimary(): String = upstreamPrimary
    fun getUpstreamFallback(): String = upstreamFallback
    fun getForwardAttempts(): Int = forwardAttempts
    fun getForwardSuccesses(): Int = forwardSuccesses
    fun getForwardFailures(): Int = forwardFailures
    fun getLastDecision(): String = lastDecision
    fun getLastError(): String = lastError

    fun runSafeDiagnosticQuery(): Boolean {
        val query = buildDnsQuery("example.com")
        val response = forwardRawDnsQuery(query, query.size)
        val success = response != null

        lastDecision = if (success) {
            "diagnostic_forward_success:example.com"
        } else {
            "diagnostic_forward_failed"
        }

        return success
    }

    fun forwardRawDnsQuery(queryBytes: ByteArray, queryLength: Int): ByteArray? {
        forwardAttempts += 1

        val safeLength = queryLength.coerceAtMost(queryBytes.size)
        if (safeLength <= 0) {
            forwardFailures += 1
            lastDecision = "raw_forward_failed_empty_query"
            lastError = "empty_query"
            return null
        }

        val query = queryBytes.copyOfRange(0, safeLength)

        val primaryResponse = sendRawDnsQuery(query, upstreamPrimary)
        if (primaryResponse != null) {
            forwardSuccesses += 1
            lastDecision = "raw_forward_success:$upstreamPrimary"
            lastError = "-"
            return primaryResponse
        }

        val fallbackResponse = sendRawDnsQuery(query, upstreamFallback)
        if (fallbackResponse != null) {
            forwardSuccesses += 1
            lastDecision = "raw_forward_success_fallback:$upstreamFallback"
            lastError = "-"
            return fallbackResponse
        }

        forwardFailures += 1
        lastDecision = "raw_forward_failed"
        lastError = "no_upstream_response"
        return null
    }

    private fun sendRawDnsQuery(query: ByteArray, upstream: String): ByteArray? {
        val socket = DatagramSocket()

        try {
            vpnService?.protect(socket)
            socket.soTimeout = 3000

            val upstreamAddress = InetAddress.getByName(upstream)
            val outbound = DatagramPacket(query, query.size, upstreamAddress, 53)
            socket.send(outbound)

            val buffer = ByteArray(4096)
            val inbound = DatagramPacket(buffer, buffer.size)
            socket.receive(inbound)

            return buffer.copyOfRange(0, inbound.length)
        } catch (error: Exception) {
            lastError = error.javaClass.simpleName
            return null
        } finally {
            socket.close()
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
            label.toByteArray(Charsets.UTF_8).forEach { output.add(it) }
        }

        output.add(0x00)
        output.add(0x00)
        output.add(0x01)
        output.add(0x00)
        output.add(0x01)

        return output.toByteArray()
    }
}
