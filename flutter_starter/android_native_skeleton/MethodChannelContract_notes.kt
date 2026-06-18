package com.focusshield.nativevpn

/**
 * MethodChannel Contract Notes
 *
 * This is not active production code.
 * It documents the future Android side of the Flutter MethodChannel contract.
 */
object MethodChannelContractNotes {
    const val VPN_CHANNEL_NAME = "focus_shield/vpn"
    const val VPN_EVENTS_CHANNEL_NAME = "focus_shield/vpn_events"

    const val METHOD_REQUEST_VPN_PERMISSION = "requestVpnPermission"
    const val METHOD_START_VPN = "startVpn"
    const val METHOD_STOP_VPN = "stopVpn"
    const val METHOD_IS_VPN_RUNNING = "isVpnRunning"
    const val METHOD_GET_VPN_STATUS = "getVpnStatus"

    const val EVENT_BLOCKED_DOMAIN = "onBlockedDomain"
    const val EVENT_VPN_STATUS_CHANGED = "onVpnStatusChanged"
    const val EVENT_VPN_ERROR = "onVpnError"

    const val STATUS_STOPPED = "stopped"
    const val STATUS_STARTING = "starting"
    const val STATUS_RUNNING = "running"
    const val STATUS_STOPPING = "stopping"
    const val STATUS_ERROR = "error"
}
