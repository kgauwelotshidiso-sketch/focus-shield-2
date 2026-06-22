package com.example.focus_shield_android

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val protectionChannelName = "focus_shield/protection"
    private val vpnPermissionRequestCode = 4207

    private val blocklistStore: FocusShieldBlocklistStore by lazy {
        FocusShieldBlocklistStore(applicationContext)
    }

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
                "prepareLiveObservation" -> prepareLiveObservation(result)
                "disableLiveObservation" -> disableLiveObservation(result)
                "openVpnSettings" -> openVpnSettings(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun startProtection(result: MethodChannel.Result) {
        val permissionIntent = VpnService.prepare(this)

        if (permissionIntent != null) {
            try {
                startActivityForResult(permissionIntent, vpnPermissionRequestCode)
                result.success("vpn_permission_screen_requested")
            } catch (_: Exception) {
                openVpnSettings(result)
            }
            return
        }

        startVpnService()
        result.success("started")
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == vpnPermissionRequestCode && resultCode == Activity.RESULT_OK) {
            startVpnService()
        }
    }

    private fun startVpnService() {
        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_START
        }

        startService(serviceIntent)
    }

    private fun stopProtection(result: MethodChannel.Result) {
        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_STOP
        }

        startService(serviceIntent)
        result.success("stopped")
    }

    private fun protectionStatus(result: MethodChannel.Result) {
        val blocklistStatus = blocklistStore.status()
        val nativeStatus = FocusShieldProtectionStatus.build(blocklistStatus)

        result.success(nativeStatus.toMap())
    }

    private fun reloadBlocklist(result: MethodChannel.Result) {
        Thread {
            val response = try {
                val success = FocusShieldDnsProxy.runForwarderDiagnostic()

                if (success) {
                    "dns_forwarder_diagnostic_success"
                } else {
                    "dns_forwarder_diagnostic_failed"
                }
            } catch (error: Exception) {
                "dns_forwarder_diagnostic_error:${error.javaClass.simpleName}"
            }

            runOnUiThread {
                result.success(response)
            }
        }.start()
    }

    private fun prepareLiveObservation(result: MethodChannel.Result) {
        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_PREPARE_LIVE_OBSERVATION
        }

        startService(serviceIntent)
        result.success("observation_prepared_locked")
    }

    private fun disableLiveObservation(result: MethodChannel.Result) {
        val serviceIntent = Intent(this, FocusShieldVpnService::class.java).apply {
            action = FocusShieldVpnService.ACTION_DISABLE_LIVE_OBSERVATION
        }

        startService(serviceIntent)
        result.success("observation_disabled")
    }

    private fun openVpnSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_VPN_SETTINGS)
            startActivity(intent)
            result.success("vpn_settings_opened")
        } catch (_: Exception) {
            result.success("vpn_settings_unavailable")
        }
    }
}
