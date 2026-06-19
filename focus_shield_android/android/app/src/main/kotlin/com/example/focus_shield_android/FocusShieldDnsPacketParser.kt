package com.example.focus_shield_android

data class FocusShieldDnsParseResult(
    val hostname: String?,
    val validDnsQuery: Boolean,
    val blocked: Boolean = false
)

class FocusShieldDnsPacketParser {
    @Volatile
    var prepared: Boolean = true
        private set

    @Volatile
    var parsedQueries: Long = 0
        private set

    @Volatile
    var lastHostname: String = ""
        private set

    fun parseQueryHostname(packet: ByteArray, length: Int): FocusShieldDnsParseResult {
        if (length <= 0 || packet.isEmpty()) {
            return FocusShieldDnsParseResult(
                hostname = null,
                validDnsQuery = false
            )
        }

        val hostname = tryParseDnsHostname(packet, length)

        if (hostname.isNullOrBlank()) {
            return FocusShieldDnsParseResult(
                hostname = null,
                validDnsQuery = false
            )
        }

        parsedQueries += 1
        lastHostname = hostname

        return FocusShieldDnsParseResult(
            hostname = hostname,
            validDnsQuery = true
        )
    }

    private fun tryParseDnsHostname(packet: ByteArray, length: Int): String? {
        val dnsStart = findLikelyDnsPayloadStart(packet, length)

        if (dnsStart < 0 || dnsStart + 12 >= length) {
            return null
        }

        val flags = readUnsignedShort(packet, dnsStart + 2)

        val isResponse = flags and 0x8000 != 0
        if (isResponse) {
            return null
        }

        val questionCount = readUnsignedShort(packet, dnsStart + 4)
        if (questionCount <= 0) {
            return null
        }

        return readQuestionName(packet, dnsStart + 12, length)
    }

    private fun findLikelyDnsPayloadStart(packet: ByteArray, length: Int): Int {
        val ipv4DnsStart = findIpv4UdpDnsStart(packet, length)

        if (ipv4DnsStart >= 0) {
            return ipv4DnsStart
        }

        return findRawDnsStart(packet, length)
    }

    private fun findIpv4UdpDnsStart(packet: ByteArray, length: Int): Int {
        if (length < 28) {
            return -1
        }

        val version = packet[0].toInt() shr 4 and 0x0F
        if (version != 4) {
            return -1
        }

        val headerLength = (packet[0].toInt() and 0x0F) * 4
        if (headerLength < 20 || length < headerLength + 8 + 12) {
            return -1
        }

        val protocol = packet[9].toInt() and 0xFF
        if (protocol != 17) {
            return -1
        }

        val udpStart = headerLength
        val sourcePort = readUnsignedShort(packet, udpStart)
        val destinationPort = readUnsignedShort(packet, udpStart + 2)

        if (sourcePort != 53 && destinationPort != 53) {
            return -1
        }

        return udpStart + 8
    }

    private fun findRawDnsStart(packet: ByteArray, length: Int): Int {
        if (length >= 12) {
            val questionCount = readUnsignedShort(packet, 4)

            if (questionCount > 0) {
                return 0
            }
        }

        return -1
    }

    private fun readQuestionName(packet: ByteArray, start: Int, length: Int): String? {
        val labels = mutableListOf<String>()
        var index = start
        var guard = 0

        while (index < length && guard < 64) {
            guard += 1

            val labelLength = packet[index].toInt() and 0xFF
            index += 1

            if (labelLength == 0) {
                break
            }

            val isPointer = labelLength and 0xC0 == 0xC0
            if (isPointer) {
                return null
            }

            if (labelLength > 63 || index + labelLength > length) {
                return null
            }

            val label = packet.copyOfRange(index, index + labelLength)
                .toString(Charsets.UTF_8)
                .trim()
                .lowercase()

            if (label.isBlank()) {
                return null
            }

            labels.add(label)
            index += labelLength
        }

        if (labels.isEmpty()) {
            return null
        }

        return labels.joinToString(".")
    }

    private fun readUnsignedShort(packet: ByteArray, offset: Int): Int {
        if (offset + 1 >= packet.size) {
            return 0
        }

        return ((packet[offset].toInt() and 0xFF) shl 8) or
            (packet[offset + 1].toInt() and 0xFF)
    }
}
