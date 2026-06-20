package com.example.focus_shield_android

import android.os.ParcelFileDescriptor
import java.io.FileInputStream
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.concurrent.thread

class FocusShieldVpnPacketLoop(
    private val dnsPacketParser: FocusShieldDnsPacketParser,
    private val dnsFilter: FocusShieldDnsFilter
) {
    var prepared: Boolean = false
        private set

    var running: Boolean = false
        private set

    var packetsObserved: Long = 0
        private set

    var ipPacketsObserved: Long = 0
        private set

    var udpPacketsObserved: Long = 0
        private set

    var tcpPacketsObserved: Long = 0
        private set

    var dnsCandidatePacketsObserved: Long = 0
        private set

    var dnsParseAttempts: Long = 0
        private set

    var dnsParseFailures: Long = 0
        private set

    var lastPacketProtocol: String = "not_started"
        private set

    var lastParserError: String = ""
        private set

    var lastPacketSummary: String = ""
        private set

    var dryRunModeReady: Boolean = false
        private set

    var dryRunBlocksDetected: Long = 0
        private set

    var lastDryRunDecision: String = ""
        private set

    private val shouldRun = AtomicBoolean(false)
    private var worker: Thread? = null

    fun prepare() {
        prepared = true
        dryRunModeReady = true
        lastPacketProtocol = "prepared"
        lastPacketSummary = "packet_loop_prepared"
    }

    fun start(
        vpnInterface: ParcelFileDescriptor?,
        liveReadEnabled: Boolean,
        dryRunModeEnabled: Boolean
    ) {
        prepared = true
        dryRunModeReady = dryRunModeEnabled

        if (!liveReadEnabled || vpnInterface == null) {
            stop()
            lastPacketProtocol = if (liveReadEnabled) {
                "vpn_interface_missing"
            } else {
                "live_read_disabled"
            }
            lastPacketSummary = "packet_loop_prepared_not_reading"
            return
        }

        if (running) {
            return
        }

        shouldRun.set(true)
        running = true
        lastPacketProtocol = "live_observation_started"
        lastPacketSummary = "packet_loop_running"

        worker = thread(
            start = true,
            isDaemon = true,
            name = "FocusShieldVpnPacketLoop"
        ) {
            try {
                val input = FileInputStream(vpnInterface.fileDescriptor)
                val buffer = ByteArray(32767)

                while (shouldRun.get()) {
                    val length = input.read(buffer)

                    if (length > 0) {
                        inspectPacket(buffer, length)
                    }
                }
            } catch (error: Exception) {
                lastParserError = "packet_loop_read_error:" + (error.message ?: "unknown")
                lastPacketSummary = lastParserError
            } finally {
                running = false
            }
        }
    }

    fun stop() {
        shouldRun.set(false)
        running = false
    }

    private fun inspectPacket(packet: ByteArray, length: Int) {
        packetsObserved += 1

        if (length < 1) {
            lastPacketProtocol = "empty"
            lastPacketSummary = "empty_packet"
            return
        }

        val version = (packet[0].toInt() shr 4) and 0x0F

        if (version != 4) {
            lastPacketProtocol = "non_ipv4"
            lastPacketSummary = "non_ipv4_packet_length_$length"
            return
        }

        if (length < 20) {
            lastPacketProtocol = "ipv4_short"
            lastPacketSummary = "ipv4_packet_too_short"
            return
        }

        ipPacketsObserved += 1

        val headerLength = (packet[0].toInt() and 0x0F) * 4

        if (headerLength < 20 || length < headerLength) {
            lastPacketProtocol = "ipv4_invalid_header"
            lastPacketSummary = "invalid_ipv4_header_length_$headerLength"
            return
        }

        val protocol = packet[9].toInt() and 0xFF

        when (protocol) {
            17 -> inspectUdpPacket(packet, length, headerLength)
            6 -> {
                tcpPacketsObserved += 1
                lastPacketProtocol = "tcp"
                lastPacketSummary = "tcp_packet_length_$length"
            }
            else -> {
                lastPacketProtocol = "ip_protocol_$protocol"
                lastPacketSummary = "ipv4_packet_protocol_$protocol"
            }
        }
    }

    private fun inspectUdpPacket(packet: ByteArray, length: Int, headerLength: Int) {
        udpPacketsObserved += 1

        if (length < headerLength + 8) {
            lastPacketProtocol = "udp_short"
            lastPacketSummary = "udp_packet_too_short"
            return
        }

        val sourcePort = readUInt16(packet, headerLength)
        val destinationPort = readUInt16(packet, headerLength + 2)

        lastPacketProtocol = "udp"
        lastPacketSummary = "udp_src_$sourcePort" + "_dst_$destinationPort"

        if (sourcePort == 53 || destinationPort == 53) {
            dnsCandidatePacketsObserved += 1
            dnsParseAttempts += 1
            lastPacketProtocol = "dns_candidate"
            lastPacketSummary = "dns_candidate_src_$sourcePort" + "_dst_$destinationPort"

            val result = dnsPacketParser.parseQueryHostname(packet.copyOf(length), length)

            if (result.parsed) {
                lastParserError = ""

                if (dnsFilter.shouldBlock(result.hostname)) {
                    dryRunBlocksDetected += 1
                    lastDryRunDecision = "would_block:" + result.hostname
                } else {
                    lastDryRunDecision = "allowed:" + result.hostname
                }
            } else {
                dnsParseFailures += 1
                lastParserError = result.error
                lastDryRunDecision = "dns_parse_failed:" + result.error
            }
        }
    }

    private fun readUInt16(packet: ByteArray, index: Int): Int {
        return ((packet[index].toInt() and 0xFF) shl 8) or
            (packet[index + 1].toInt() and 0xFF)
    }
}
