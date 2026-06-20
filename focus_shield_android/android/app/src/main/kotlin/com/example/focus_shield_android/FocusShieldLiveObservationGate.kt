package com.example.focus_shield_android

object FocusShieldLiveObservationGate {
    const val gateVersion: Int = 2

    const val unlockedByCode: Boolean = true

    const val unlockReason: String =
        "unlocked_for_live_observation_only_blocking_disabled"

    const val allowedProtectionModeWhenUnlocked: String =
        "live_observation_only"

    fun canEnableLiveObservation(): Boolean {
        return unlockedByCode
    }

    fun gateStatus(): String {
        return if (unlockedByCode) {
            "unlocked_by_code"
        } else {
            unlockReason
        }
    }
}
