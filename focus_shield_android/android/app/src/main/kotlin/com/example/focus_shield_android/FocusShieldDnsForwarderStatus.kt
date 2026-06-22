package com.example.focus_shield_android

data class FocusShieldDnsForwarderStatus(
    val dnsForwarderPrepared: Boolean,
    val dnsForwarderEnabled: Boolean,
    val dnsForwarderMode: String,
    val upstreamPrimary: String,
    val upstreamFallback: String,
    val forwardAttempts: Int,
    val forwardSuccesses: Int,
    val forwardFailures: Int,
    val lastForwarderDecision: String,
    val lastForwarderError: String,
)
