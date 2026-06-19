package com.example.focus_shield_android

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class FocusShieldDnsPacketParserTest {
    @Test
    fun parsesRawDnsQueryHostname() {
        val parser = FocusShieldDnsPacketParser()
        val packet = buildRawDnsQuery("blocked-example.com")

        val result = parser.parseQueryHostname(packet, packet.size)

        assertTrue(result.validDnsQuery)
        assertEquals("blocked-example.com", result.hostname)
        assertEquals(1, parser.parsedQueries)
        assertEquals("blocked-example.com", parser.lastHostname)
    }

    @Test
    fun rejectsEmptyPacket() {
        val parser = FocusShieldDnsPacketParser()
        val packet = ByteArray(0)

        val result = parser.parseQueryHostname(packet, packet.size)

        assertFalse(result.validDnsQuery)
        assertEquals(null, result.hostname)
        assertEquals(0, parser.parsedQueries)
    }

    @Test
    fun filterBlocksExactDomainAndSubdomain() {
        val filter = FocusShieldDnsFilter()

        filter.reload(listOf("blocked-example.com"))

        assertTrue(filter.shouldBlock("blocked-example.com"))
        assertTrue(filter.shouldBlock("sub.blocked-example.com"))
        assertFalse(filter.shouldBlock("safe-example.com"))
    }

    private fun buildRawDnsQuery(hostname: String): ByteArray {
        val packet = mutableListOf<Byte>()

        packet.addAll(
            listOf(
                0x12, 0x34,
                0x01, 0x00,
                0x00, 0x01,
                0x00, 0x00,
                0x00, 0x00,
                0x00, 0x00
            ).map { it.toByte() }
        )

        hostname.split(".").forEach { label ->
            packet.add(label.length.toByte())
            label.toByteArray(Charsets.UTF_8).forEach { packet.add(it) }
        }

        packet.add(0x00)
        packet.add(0x00)
        packet.add(0x01)
        packet.add(0x00)
        packet.add(0x01)

        return packet.toByteArray()
    }
}
