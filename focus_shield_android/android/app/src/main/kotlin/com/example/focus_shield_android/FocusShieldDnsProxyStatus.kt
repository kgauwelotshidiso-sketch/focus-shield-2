package com.example.focus_shield_android

data class FocusShieldDnsProxyStatus(
    val dnsProxyPrepared: Boolean,
    val dnsProxyRunning: Boolean,
    val dnsProxyMode: String,
    val dnsProxyQueriesReceived: Long,
    val dnsProxyQueriesForwarded: Long,
    val dnsProxyResponsesReturned: Long,
    val dnsProxyErrors: Long,
    val lastDnsProxyHost: String,
    val lastDnsProxyDecision: String,
    val lastDnsProxyError: String
)
