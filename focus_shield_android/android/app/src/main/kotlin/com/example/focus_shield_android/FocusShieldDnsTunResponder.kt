package com.example.focus_shield_android

object FocusShieldDnsTunResponder {
    const val ENGINE_VERSION = "ipv4_dns_response_builder_v1"

    fun isDnsTunResponseEngineReady(): Boolean = true

    fun buildIpv4UdpDnsResponsePacket(
        queryPacket: ByteArray,
        queryLength: Int,
        dnsResponse: ByteArray,
    ): ByteArray? {
        if (queryLength < 28 || dnsResponse.isEmpty()) return null

        val version = (queryPacket[0].toInt() ushr 4) and 0x0F
        if (version != 4) return null

        val ihl = (queryPacket[0].toInt() and 0x0F) * 4
        if (ihl < 20 || queryLength < ihl + 8) return null

        val protocol = queryPacket[9].toInt() and 0xFF
        if (protocol != 17) return null

        val udpOffset = ihl
        val sourcePort = readU16(queryPacket, udpOffset)
        val destinationPort = readU16(queryPacket, udpOffset + 2)

        if (destinationPort != 53) return null

        val totalLength = 20 + 8 + dnsResponse.size
        val responsePacket = ByteArray(totalLength)

        responsePacket[0] = 0x45.toByte()
        responsePacket[1] = 0
        writeU16(responsePacket, 2, totalLength)

        responsePacket[4] = queryPacket[4]
        responsePacket[5] = queryPacket[5]
        responsePacket[6] = 0
        responsePacket[7] = 0
        responsePacket[8] = 64
        responsePacket[9] = 17

        responsePacket[12] = queryPacket[16]
        responsePacket[13] = queryPacket[17]
        responsePacket[14] = queryPacket[18]
        responsePacket[15] = queryPacket[19]

        responsePacket[16] = queryPacket[12]
        responsePacket[17] = queryPacket[13]
        responsePacket[18] = queryPacket[14]
        responsePacket[19] = queryPacket[15]

        writeU16(responsePacket, 10, ipv4HeaderChecksum(responsePacket))

        val responseUdpOffset = 20
        writeU16(responsePacket, responseUdpOffset, destinationPort)
        writeU16(responsePacket, responseUdpOffset + 2, sourcePort)
        writeU16(responsePacket, responseUdpOffset + 4, 8 + dnsResponse.size)
        writeU16(responsePacket, responseUdpOffset + 6, 0)

        dnsResponse.copyInto(responsePacket, responseUdpOffset + 8)

        return responsePacket
    }

    fun canBuildResponseFromCapturedDnsPacket(
        packet: ByteArray,
        length: Int,
        dnsResponse: ByteArray,
    ): Boolean {
        return buildIpv4UdpDnsResponsePacket(packet, length, dnsResponse) != null
    }

    private fun readU16(bytes: ByteArray, offset: Int): Int {
        return ((bytes[offset].toInt() and 0xFF) shl 8) or
            (bytes[offset + 1].toInt() and 0xFF)
    }

    private fun writeU16(bytes: ByteArray, offset: Int, value: Int) {
        bytes[offset] = ((value ushr 8) and 0xFF).toByte()
        bytes[offset + 1] = (value and 0xFF).toByte()
    }

    private fun ipv4HeaderChecksum(header: ByteArray): Int {
        var sum = 0
        var index = 0

        while (index < 20) {
            if (index != 10) sum += readU16(header, index)
            index += 2
        }

        while ((sum ushr 16) != 0) {
            sum = (sum and 0xFFFF) + (sum ushr 16)
        }

        return sum.inv() and 0xFFFF
    }
}
