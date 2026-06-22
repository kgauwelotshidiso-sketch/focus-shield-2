package com.example.focus_shield_android

object FocusShieldDnsTunForwardingEngine {
    const val ENGINE_VERSION = "dns_tun_forwarding_engine_v1"

    fun forwardCapturedDnsPacket(packet: ByteArray, length: Int): ByteArray? {
        val dnsQuery = extractIpv4UdpDnsQuery(packet, length) ?: return null
        val dnsResponse = FocusShieldDnsForwarder.forwardRawDnsQuery(dnsQuery, dnsQuery.size) ?: return null

        return FocusShieldDnsTunResponder.buildIpv4UdpDnsResponsePacket(
            queryPacket = packet,
            queryLength = length,
            dnsResponse = dnsResponse,
        )
    }

    fun canForwardCapturedDnsPacket(packet: ByteArray, length: Int): Boolean {
        return extractIpv4UdpDnsQuery(packet, length) != null
    }

    private fun extractIpv4UdpDnsQuery(packet: ByteArray, length: Int): ByteArray? {
        if (length < 28) return null

        val version = (packet[0].toInt() ushr 4) and 0x0F
        if (version != 4) return null

        val ihl = (packet[0].toInt() and 0x0F) * 4
        if (ihl < 20 || length < ihl + 8) return null

        val protocol = packet[9].toInt() and 0xFF
        if (protocol != 17) return null

        val udpOffset = ihl
        val destinationPort = readU16(packet, udpOffset + 2)
        if (destinationPort != 53) return null

        val udpLength = readU16(packet, udpOffset + 4)
        if (udpLength < 8) return null

        val dnsOffset = udpOffset + 8
        val dnsLength = udpLength - 8

        if (dnsOffset + dnsLength > length) return null

        return packet.copyOfRange(dnsOffset, dnsOffset + dnsLength)
    }

    private fun readU16(bytes: ByteArray, offset: Int): Int {
        return ((bytes[offset].toInt() and 0xFF) shl 8) or
            (bytes[offset + 1].toInt() and 0xFF)
    }
}
