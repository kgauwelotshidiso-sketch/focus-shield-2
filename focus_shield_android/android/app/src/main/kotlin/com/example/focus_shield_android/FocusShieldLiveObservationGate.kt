package com.example.focus_shield_android

object FocusShieldLiveObservationGate {
    const val gateVersion: Int = 1

    const val unlockedByCode: Boolean = false

    const val unlockReason: String =
        "locked_until_live_observation_regression_tests_are_documented"

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
