package com.example.focus_shield_android

data class FocusShieldDnsProxyStatus(
    val dnsProxyPrepared: Boolean,
    val dnsProxyRunning: Boolean,
    val dnsProxyMode: String,
    val dnsProxyQueriesReceived: Int,
    val dnsProxyQueriesForwarded: Int,
    val dnsProxyResponsesReturned: Int,
    val dnsProxyErrors: Int,
    val lastDnsProxyHost: String,
    val lastDnsProxyDecision: String,
    val lastDnsProxyError: String,
)
