# Android Manifest Requirements for VPN Filtering

Phase 3 will require Android permissions and service declarations.

## Required Permission

android.permission.FOREGROUND_SERVICE

For Android 13+ notification support may also require:

android.permission.POST_NOTIFICATIONS

## Required VPN Service

The AndroidManifest will need a service using:

android.permission.BIND_VPN_SERVICE

Intent action:

android.net.VpnService

## Important

The service must not be added blindly until the Kotlin service file exists.

Add manifest changes together with the native service skeleton.
