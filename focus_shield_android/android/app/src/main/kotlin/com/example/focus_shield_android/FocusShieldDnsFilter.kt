package com.example.focus_shield_android

class FocusShieldDnsFilter {
    private var blockedDomains: Set<String> = emptySet()

    fun reload(domains: List<String>) {
        blockedDomains = domains
            .map { normalizeDomain(it) }
            .filter { it.isNotEmpty() }
            .toSet()
    }

    fun shouldBlock(hostname: String?): Boolean {
        val normalizedHost = normalizeDomain(hostname ?: "")

        if (normalizedHost.isEmpty()) {
            return false
        }

        return blockedDomains.any { blockedDomain ->
            normalizedHost == blockedDomain || normalizedHost.endsWith(".$blockedDomain")
        }
    }

    fun blockedDomainCount(): Int {
        return blockedDomains.size
    }

    fun hasBlocklist(): Boolean {
        return blockedDomains.isNotEmpty()
    }

    private fun normalizeDomain(value: String): String {
        return value
            .trim()
            .lowercase()
            .removePrefix("http://")
            .removePrefix("https://")
            .removePrefix("www.")
            .substringBefore("/")
            .substringBefore(":")
    }
}
