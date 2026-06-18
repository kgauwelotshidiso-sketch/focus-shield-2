package com.focusshield.nativevpn

/**
 * DomainDecisionBridge
 *
 * Starter skeleton only.
 *
 * Future responsibility:
 * - Send domain to Flutter/Dart ProtectionEngine through MethodChannel
 * - Receive ALLOW or BLOCK decision
 * - Keep native layer away from direct SQLite writes
 */
class DomainDecisionBridge {
    data class DomainDecision(
        val shouldBlock: Boolean,
        val domain: String,
        val category: String,
        val reason: String,
        val confidence: Double
    )

    suspend fun decide(domain: String): DomainDecision {
        // TODO Phase 4:
        // Call Flutter MethodChannel or local decision bridge.
        return DomainDecision(
            shouldBlock = false,
            domain = domain,
            category = "unknown",
            reason = "Starter bridge allows by default until engine is connected",
            confidence = 0.0
        )
    }
}
