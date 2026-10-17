package com.lyramusic.lyra

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Canal « lyra/system » : volume média, widgets, écran de verrouillage.
 * N'utilise que le contexte de l'application : le moteur Flutter (gardé par
 * audio_service) continue de fonctionner quand l'activité est fermée.
 */
class SystemChannel(private val app: Context, messenger: BinaryMessenger) {
    init {
        LockScreen.ensure(app)
        MethodChannel(messenger, "lyra/system").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "updateNowPlaying" -> {
                        NowPlaying.save(
                            app,
                            NowPlaying.State(
                                call.argument<String>("title"),
                                call.argument<String>("artist"),
                                call.argument<String>("art"),
                                call.argument<Boolean>("playing") ?: false,
                            ),
                        )
                        result.success(null)
                    }
                    "getVolume" -> {
                        val am = app.getSystemService(AudioManager::class.java)
                        result.success(
                            mapOf(
                                "current" to am.getStreamVolume(AudioManager.STREAM_MUSIC),
                                "max" to am.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
                            )
                        )
                    }
                    "setVolume" -> {
                        val am = app.getSystemService(AudioManager::class.java)
                        am.setStreamVolume(AudioManager.STREAM_MUSIC, call.argument<Int>("value") ?: 0, 0)
                        result.success(null)
                    }
                    "lockScreenAllowed" -> result.success(LockScreen.allowed(app))
                    "setLockScreenEnabled" -> {
                        LockScreen.setEnabled(app, call.argument<Boolean>("enabled") ?: false)
                        result.success(null)
                    }
                    "requestLockScreenPermission" -> {
                        openPermissionSettings()
                        result.success(null)
                    }
                    "pinWidget" -> result.success(LyraWidgets.pin(app, call.argument<String>("kind") ?: "small"))
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error(e.javaClass.simpleName, e.message, null)
            }
        }
    }

    private fun openPermissionSettings() {
        val pkg = Uri.parse("package:${app.packageName}")
        val lowRam = app.getSystemService(ActivityManager::class.java).isLowRamDevice
        val nm = app.getSystemService(android.app.NotificationManager::class.java)
        val intent = when {
            !nm.areNotificationsEnabled() ->
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, app.packageName)
            Build.VERSION.SDK_INT >= 34 && !nm.canUseFullScreenIntent() ->
                Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, pkg)
            // Android Go ne propose pas « Afficher par-dessus les autres applis ».
            !lowRam -> Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, pkg)
            else -> Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, pkg)
        }
        app.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }
}
