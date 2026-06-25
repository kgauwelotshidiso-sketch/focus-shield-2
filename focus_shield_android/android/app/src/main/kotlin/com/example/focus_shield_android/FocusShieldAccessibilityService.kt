package com.example.focus_shield_android

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class FocusShieldAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Phase 4B scaffold.
        // The user must enable this manually in Android Accessibility Settings.
        // Website text detection will be connected after this service is confirmed visible and stable.
    }

    override fun onInterrupt() {
        // No-op.
    }
}
