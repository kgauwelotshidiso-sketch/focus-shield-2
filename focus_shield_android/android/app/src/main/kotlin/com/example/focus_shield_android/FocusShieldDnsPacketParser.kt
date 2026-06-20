package com.example.focus_shield_android

data class FocusShieldDnsParseResult(
    val parsed: Boolean,
    val hostname: String,
    val error: String
) {
    val success: Boolean
        get() = parsed

    val isDnsQuery: Boolean
        get() = parsed
}

class FocusShieldDnsPacketParser {
    var prepared: Boolean = true
        private set

    var parsedQueries: Long = 0
        private set

    var lastHostname: String = ""
        private set

    var parseAttempts: Long = 0
        private set

    var parseFailures: Long = 0
        private set

    var lastParserError: String = ""
        private set

    fun prepare() {
        prepared = true
    }

    fun parseQueryHostname(packet: ByteArray, length: Int): FocusShieldDnsParseResult {
        prepared = true
        parseAttempts += 1

        if (length < 12) {
            return fail("packet_too_short")
        }

        val dnsOffset = detectDnsOffset(packet, length)

        if (dnsOffset < 0 || dnsOffset + 12 > length) {
            return fail("dns_payload_not_found")
        }

        return try {
            val qdCount = readUInt16(packet, dnsOffset + 4)

            if (qdCount <= 0) {
                return fail("dns_question_count_zero")
            }

            val labels = mutableListOf<String>()
            var cursor = dnsOffset + 12
            var guard = 0

            while (cursor < length && guard < 40) {
                guard += 1

                val labelLength = packet[cursor].toInt() and 0xFF
                cursor += 1

                if (labelLength == 0) {
                    break
                }

                if ((labelLength and 0xC0) == 0xC0) {
                    return fail("compressed_dns_name_not_supported_in_question")
                }

                if (labelLength > 63) {
                    return fail("invalid_dns_label_length")
                }

                if (cursor + labelLength > length) {
                    return fail("dns_label_out_of_bounds")
                }

                val label = packet.copyOfRange(cursor, cursor + labelLength)
                    .toString(Charsets.UTF_8)

                labels.add(label)
                cursor += labelLength
            }

            if (labels.isEmpty()) {
                return fail("empty_dns_hostname")
            }

            val hostname = labels.joinToString(".").lowercase()

            parsedQueries += 1
            lastHostname = hostname
            lastParserError = ""

            FocusShieldDnsParseResult(
                parsed = true,
                hostname = hostname,
                error = ""
            )
        } catch (error: Exception) {
            fail("dns_parse_exception:" + (error.message ?: "unknown"))
        }
    }

    private fun detectDnsOffset(packet: ByteArray, length: Int): Int {
        if (length >= 1) {
            val version = (packet[0].toInt() shr 4) and 0x0F

            if (version == 4 && length >= 28) {
                val headerLength = (packet[0].toInt() and 0x0F) * 4
                val protocol = packet[9].toInt() and 0xFF

                if (protocol == 17 && length >= headerLength + 8 + 12) {
                    val sourcePort = readUInt16(packet, headerLength)
                    val destinationPort = readUInt16(packet, headerLength + 2)

                    if (sourcePort == 53 || destinationPort == 53) {
                        return headerLength + 8
                    }
                }
            }

            if (version == 6 && length >= 40 + 8 + 12) {
                val nextHeader = packet[6].toInt() and 0xFF
                val transportOffset = 40

                if (nextHeader == 17) {
                    val sourcePort = readUInt16(packet, transportOffset)
                    val destinationPort = readUInt16(packet, transportOffset + 2)

                    if (sourcePort == 53 || destinationPort == 53) {
                        return transportOffset + 8
                    }
                }
            }
        }

        if (looksLikeDnsMessage(packet, 0, length)) {
            return 0
        }

        return -1
    }

    private fun looksLikeDnsMessage(packet: ByteArray, offset: Int, length: Int): Boolean {
        if (offset + 12 > length) {
            return false
        }

        val qdCount = readUInt16(packet, offset + 4)
        return qdCount in 1..10
    }

    private fun readUInt16(packet: ByteArray, index: Int): Int {
        return ((packet[index].toInt() and 0xFF) shl 8) or
            (packet[index + 1].toInt() and 0xFF)
    }

    private fun fail(reason: String): FocusShieldDnsParseResult {
        parseFailures += 1
        lastParserError = reason

        return FocusShieldDnsParseResult(
            parsed = false,
            hostname = "",
            error = reason
        )
    }
}
