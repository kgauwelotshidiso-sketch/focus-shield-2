package com.example.focus_shield_android

data class FocusShieldDnsForwarderStatus(
    val dnsForwarderPrepared: Boolean,
    val dnsForwarderEnabled: Boolean,
    val dnsForwarderMode: String,
    val upstreamPrimary: String,
    val upstreamFallback: String,
    val forwardAttempts: Long,
    val forwardSuccesses: Long,
    val forwardFailures: Long,
    val lastForwarderDecision: String,
    val lastForwarderError: String
)
