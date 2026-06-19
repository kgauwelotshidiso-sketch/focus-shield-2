package com.example.focus_shield_android

import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val protectionChannelName = "focus_shield/protection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            protectionChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startProtection" -> startProtection(result)
                "stopProtection" -> stopProtection(result)
                "protectionStatus" -> protectionStatus(result)
                "reloadBlocklist" -> reloadBlocklist(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun startProtection(result: MethodChannel.Result) {
        val permissionIntent = VpnService.prepare(this)

        if (permissionIntent != null) {
            startActivity(permissionIntent)
            result.success("permission_required")
            return
        }

        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_START
        }

        startService(serviceIntent)
        result.success("started")
    }

    private fun stopProtection(result: MethodChannel.Result) {
        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_STOP
        }

        startService(serviceIntent)
        result.success("stopped")
    }

    private fun protectionStatus(result: MethodChannel.Result) {
        result.success(
            mapOf(
                "vpnActive" to FocusShieldVpnService.isRunning,
                "blocklistLoaded" to true,
                "blockedDomainCount" to 0
            )
        )
    }

    private fun reloadBlocklist(result: MethodChannel.Result) {
        result.success("reloaded")
    }
}
