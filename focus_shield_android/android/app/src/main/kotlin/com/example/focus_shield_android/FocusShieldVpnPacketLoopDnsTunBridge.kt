package com.example.focus_shield_android

import java.io.OutputStream

object FocusShieldVpnPacketLoopDnsTunBridge {
    const val BRIDGE_VERSION = "packet_loop_dns_tun_output_bridge_v1"

    private var prepared: Boolean = true
    private var responsesBuilt: Int = 0
    private var responsesWritten: Int = 0
    private var failures: Int = 0
    private var lastDecision: String = "packet_loop_dns_tun_output_bridge_ready"

    fun isPrepared(): Boolean = prepared
    fun getResponsesBuilt(): Int = responsesBuilt
    fun getResponsesWritten(): Int = responsesWritten
    fun getFailures(): Int = failures
    fun getLastDecision(): String = lastDecision

    fun tryBuildResponse(packet: ByteArray, length: Int): ByteArray? {
        val response = FocusShieldDnsTunForwardingEngine.forwardCapturedDnsPacket(packet, length)

        return if (response != null) {
            responsesBuilt += 1
            lastDecision = "packet_loop_dns_tun_response_built"
            response
        } else {
            failures += 1
            lastDecision = "packet_loop_dns_tun_response_not_built"
            null
        }
    }

    fun tryForwardAndWriteResponse(
        outputStream: OutputStream,
        packet: ByteArray,
        length: Int,
    ): Boolean {
        val response = tryBuildResponse(packet, length) ?: return false

        return try {
            outputStream.write(response)
            outputStream.flush()
            responsesWritten += 1
            lastDecision = "packet_loop_dns_tun_response_written"
            true
        } catch (error: Exception) {
            failures += 1
            lastDecision = "packet_loop_dns_tun_write_failed:${error.javaClass.simpleName}"
            false
        }
    }
}
