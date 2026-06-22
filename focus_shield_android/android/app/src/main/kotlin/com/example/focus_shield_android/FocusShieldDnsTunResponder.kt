package com.example.focus_shield_android

object FocusShieldDnsTunResponder {
    fun isDnsTunResponseEngineReady(): Boolean {
        return true
    }

    fun canBuildResponseFromCapturedDnsPacket(
        packet: ByteArray,
        length: Int,
        dnsResponse: ByteArray,
    ): Boolean {
        if (length < 28) return false
        if (dnsResponse.isEmpty()) return false

        val version = (packet[0].toInt() ushr 4) and 0x0F

        return version == 4 || version == 6
    }
}
