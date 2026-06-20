package com.example.focus_shield_android

enum class FocusShieldDnsProxyMode(val label: String) {
    DISABLED("disabled"),
    DNS_PROXY_DIAGNOSTIC_ONLY("dns_proxy_diagnostic_only"),
    DNS_PROXY_DRY_RUN("dns_proxy_dry_run"),
    DNS_PROXY_BLOCKING_CANDIDATE("dns_proxy_blocking_candidate")
}
