package com.lyramusic.lyra

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.os.Build
import android.provider.Settings

/**
 * Morceau en cours, partagé entre l'application (Dart), les widgets
 * et l'écran de verrouillage. Conservé dans les SharedPreferences pour
 * que les widgets l'affichent même quand l'application est fermée.
 */
object NowPlaying {
    private const val PREFS = "lyra_now_playing"

    data class State(val title: String?, val artist: String?, val art: String?, val playing: Boolean)

    fun save(ctx: Context, s: State) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString("title", s.title)
            .putString("artist", s.artist)
            .putString("art", s.art)
            .putBoolean("playing", s.playing)
            .apply()
        LyraWidgets.updateAll(ctx, s)
    }

    fun load(ctx: Context): State {
        val p = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return State(p.getString("title", null), p.getString("artist", null), p.getString("art", null), p.getBoolean("playing", false))
    }

    /** Pochette réduite et arrondie (les widgets ne savent pas arrondir les images). */
    fun artBitmap(path: String?, size: Int, radiusFraction: Float): Bitmap? {
        if (path == null) return null
        return try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, bounds)
            var sample = 1
            while (bounds.outWidth / (sample * 2) >= size) sample *= 2
            val src = BitmapFactory.decodeFile(path, BitmapFactory.Options().apply { inSampleSize = sample }) ?: return null
            val scaled = Bitmap.createScaledBitmap(src, size, size, true)
            val out = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { shader = BitmapShader(scaled, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP) }
            val r = size * radiusFraction
            Canvas(out).drawRoundRect(RectF(0f, 0f, size.toFloat(), size.toFloat()), r, r, paint)
            out
        } catch (e: Exception) {
            null
        }
    }
}

/**
 * Écran de verrouillage LyraMusic : quand l'écran s'éteint pendant la lecture,
 * on affiche le lecteur par-dessus l'écran verrouillé.
 *
 * Deux moyens selon ce qu'autorise le téléphone :
 * - « Afficher par-dessus les autres applis » (indisponible sur Android Go) ;
 * - une notification plein écran (Android 14 : autorisation à accorder une fois).
 */
object LockScreen {
    private const val PREFS = "lyra_lock_screen"
    private const val CHANNEL = "lyra_lock_screen"
    const val NOTIFICATION_ID = 4310
    private var receiver: BroadcastReceiver? = null

    fun isEnabled(ctx: Context) = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean("enabled", false)

    fun setEnabled(ctx: Context, enabled: Boolean) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean("enabled", enabled).apply()
        if (enabled) register(ctx.applicationContext) else unregister(ctx.applicationContext)
    }

    fun canUseOverlay(ctx: Context) = Settings.canDrawOverlays(ctx)

    fun canUseFullScreen(ctx: Context): Boolean {
        val nm = ctx.getSystemService(NotificationManager::class.java)
        if (!nm.areNotificationsEnabled()) return false
        return Build.VERSION.SDK_INT < 34 || nm.canUseFullScreenIntent()
    }

    fun allowed(ctx: Context) = canUseOverlay(ctx) || canUseFullScreen(ctx)

    /** À appeler au démarrage : réactive l'écoute si l'option est active. */
    fun ensure(ctx: Context) {
        if (isEnabled(ctx)) register(ctx.applicationContext)
    }

    private fun register(app: Context) {
        if (receiver != null) return
        val r = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action == Intent.ACTION_SCREEN_OFF && NowPlaying.load(context).playing) show(context)
            }
        }
        app.registerReceiver(r, IntentFilter(Intent.ACTION_SCREEN_OFF))
        receiver = r
    }

    private fun unregister(app: Context) {
        receiver?.let { runCatching { app.unregisterReceiver(it) } }
        receiver = null
    }

    fun show(ctx: Context) {
        val intent = Intent(ctx, LockScreenActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_USER_ACTION or Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
        if (canUseOverlay(ctx)) {
            runCatching { ctx.startActivity(intent) }
            return
        }
        if (!canUseFullScreen(ctx)) return
        val nm = ctx.getSystemService(NotificationManager::class.java)
        if (nm.getNotificationChannel(CHANNEL) == null) {
            nm.createNotificationChannel(
                NotificationChannel(CHANNEL, ctx.getString(R.string.lock_channel_name), NotificationManager.IMPORTANCE_HIGH).apply {
                    setSound(null, null)
                    enableVibration(false)
                    setShowBadge(false)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
            )
        }
        val pi = PendingIntent.getActivity(ctx, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val now = NowPlaying.load(ctx)
        val n = Notification.Builder(ctx, CHANNEL)
            .setSmallIcon(R.drawable.ic_stat_lyra)
            .setContentTitle(now.title ?: "LyraMusic")
            .setContentText(now.artist)
            .setCategory(Notification.CATEGORY_TRANSPORT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setFullScreenIntent(pi, true)
            .setContentIntent(pi)
            .setAutoCancel(true)
            .setTimeoutAfter(10_000)
            .build()
        nm.notify(NOTIFICATION_ID, n)
    }
}
