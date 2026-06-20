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

    var ipv6PacketsObserved: Long = 0
        private set

    var udpPacketsObserved: Long = 0
        private set

    var ipv6UdpPacketsObserved: Long = 0
        private set

    var tcpPacketsObserved: Long = 0
        private set

    var ipv6TcpPacketsObserved: Long = 0
        private set

    var dnsCandidatePacketsObserved: Long = 0
        private set

    var ipv6DnsCandidatePacketsObserved: Long = 0
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

        when (version) {
            4 -> inspectIpv4Packet(packet, length)
            6 -> inspectIpv6Packet(packet, length)
            else -> {
                lastPacketProtocol = "unknown_ip_version_$version"
                lastPacketSummary = "unknown_ip_version_$$version" + "_length_$length"
            }
        }
    }

    private fun inspectIpv4Packet(packet: ByteArray, length: Int) {
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
            17 -> inspectUdpPacket(
                packet = packet,
                length = length,
                transportOffset = headerLength,
                isIpv6 = false
            )
            6 -> {
                tcpPacketsObserved += 1
                lastPacketProtocol = "ipv4_tcp"
                lastPacketSummary = "ipv4_tcp_packet_length_$length"
            }
            else -> {
                lastPacketProtocol = "ipv4_protocol_$protocol"
                lastPacketSummary = "ipv4_packet_protocol_$protocol"
            }
        }
    }

    private fun inspectIpv6Packet(packet: ByteArray, length: Int) {
        if (length < 40) {
            lastPacketProtocol = "ipv6_short"
            lastPacketSummary = "ipv6_packet_too_short"
            return
        }

        ipv6PacketsObserved += 1

        val nextHeader = packet[6].toInt() and 0xFF
        val transportOffset = 40

        when (nextHeader) {
            17 -> inspectUdpPacket(
                packet = packet,
                length = length,
                transportOffset = transportOffset,
                isIpv6 = true
            )
            6 -> {
                ipv6TcpPacketsObserved += 1
                lastPacketProtocol = "ipv6_tcp"
                lastPacketSummary = "ipv6_tcp_packet_length_$length"
            }
            58 -> {
                lastPacketProtocol = "ipv6_icmpv6"
                lastPacketSummary = "ipv6_icmpv6_packet_length_$length"
            }
            else -> {
                lastPacketProtocol = "ipv6_next_header_$nextHeader"
                lastPacketSummary = "ipv6_packet_next_header_$nextHeader"
            }
        }
    }

    private fun inspectUdpPacket(
        packet: ByteArray,
        length: Int,
        transportOffset: Int,
        isIpv6: Boolean
    ) {
        if (length < transportOffset + 8) {
            lastPacketProtocol = if (isIpv6) "ipv6_udp_short" else "ipv4_udp_short"
            lastPacketSummary = "udp_packet_too_short"
            return
        }

        if (isIpv6) {
            ipv6UdpPacketsObserved += 1
        } else {
            udpPacketsObserved += 1
        }

        val sourcePort = readUInt16(packet, transportOffset)
        val destinationPort = readUInt16(packet, transportOffset + 2)

        lastPacketProtocol = if (isIpv6) "ipv6_udp" else "ipv4_udp"
        lastPacketSummary = if (isIpv6) {
            "ipv6_udp_src_$sourcePort" + "_dst_$destinationPort"
        } else {
            "ipv4_udp_src_$sourcePort" + "_dst_$destinationPort"
        }

        if (sourcePort == 53 || destinationPort == 53) {
            dnsCandidatePacketsObserved += 1

            if (isIpv6) {
                ipv6DnsCandidatePacketsObserved += 1
            }

            dnsParseAttempts += 1
            lastPacketProtocol = if (isIpv6) "ipv6_dns_candidate" else "ipv4_dns_candidate"
            lastPacketSummary = if (isIpv6) {
                "ipv6_dns_candidate_src_$sourcePort" + "_dst_$destinationPort"
            } else {
                "ipv4_dns_candidate_src_$sourcePort" + "_dst_$destinationPort"
            }

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
