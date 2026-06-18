package com.focusshield.nativevpn

/**
 * VpnStatusReceiver
 *
 * Starter skeleton only.
 *
 * Future responsibility:
 * - Track VPN status changes
 * - Notify Flutter UI when protection is running, stopped, or needs attention
 */
class VpnStatusReceiver {
    enum class Status {
        STOPPED,
        STARTING,
        RUNNING,
        ERROR
    }

    private var currentStatus: Status = Status.STOPPED

    fun updateStatus(status: Status) {
        currentStatus = status
        // TODO Phase 4:
        // Send status to Flutter through MethodChannel/event stream.
    }

    fun getStatus(): Status {
        return currentStatus
    }
}
