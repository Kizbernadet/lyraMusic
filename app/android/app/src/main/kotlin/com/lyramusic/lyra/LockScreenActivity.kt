package com.lyramusic.lyra

import android.app.Activity
import android.app.NotificationManager
import android.content.ComponentName
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Outline
import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaControllerCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.view.ViewOutlineProvider
import android.view.WindowManager
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import com.ryanheise.audioservice.AudioService
import kotlin.math.abs

/**
 * Lecteur affiché par-dessus l'écran verrouillé (option « Écran de verrouillage
 * LyraMusic »). Interface native reliée à la session média du lecteur :
 * fonctionne même quand l'interface Flutter n'est pas ouverte.
 * Glisser vers le haut (ou retour) pour retrouver l'écran de verrouillage du téléphone.
 */
class LockScreenActivity : Activity() {
    private var browser: MediaBrowserCompat? = null
    private var controller: MediaControllerCompat? = null
    private val main = Handler(Looper.getMainLooper())
    private lateinit var art: ImageView
    private lateinit var background: ImageView
    private lateinit var title: TextView
    private lateinit var artist: TextView
    private lateinit var progress: ProgressBar
    private lateinit var elapsed: TextView
    private lateinit var total: TextView
    private lateinit var play: ImageButton
    private var lastArt: Any? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= 27) {
            setShowWhenLocked(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        }
        getSystemService(NotificationManager::class.java).cancel(LockScreen.NOTIFICATION_ID)
        setContentView(R.layout.activity_lock_screen)

        art = findViewById(R.id.lock_art)
        background = findViewById(R.id.lock_background)
        title = findViewById(R.id.lock_title)
        artist = findViewById(R.id.lock_artist)
        progress = findViewById(R.id.lock_progress)
        elapsed = findViewById(R.id.lock_elapsed)
        total = findViewById(R.id.lock_total)
        play = findViewById(R.id.lock_play)

        art.clipToOutline = true
        art.outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) =
                outline.setRoundRect(0, 0, view.width, view.height, 24 * resources.displayMetrics.density)
        }
        if (Build.VERSION.SDK_INT >= 31) {
            background.setRenderEffect(RenderEffect.createBlurEffect(80f, 80f, Shader.TileMode.CLAMP))
        }

        findViewById<ImageButton>(R.id.lock_prev).setOnClickListener { controller?.transportControls?.skipToPrevious() }
        findViewById<ImageButton>(R.id.lock_next).setOnClickListener { controller?.transportControls?.skipToNext() }
        play.setOnClickListener {
            val c = controller ?: return@setOnClickListener
            if (c.playbackState?.state == PlaybackStateCompat.STATE_PLAYING) c.transportControls.pause() else c.transportControls.play()
        }

        // Glisser vers le haut : retour à l'écran de verrouillage du téléphone.
        val detector = GestureDetector(this, object : GestureDetector.SimpleOnGestureListener() {
            override fun onDown(e: MotionEvent) = true
            override fun onFling(e1: MotionEvent?, e2: MotionEvent, vx: Float, vy: Float): Boolean {
                if (vy < -800 && abs(vy) > abs(vx)) {
                    dismiss()
                    return true
                }
                return false
            }
        })
        findViewById<View>(R.id.lock_root).setOnTouchListener { v, e ->
            if (e.action == MotionEvent.ACTION_UP) v.performClick()
            detector.onTouchEvent(e)
        }

        // Valeurs connues tout de suite, avant la connexion à la session.
        val saved = NowPlaying.load(this)
        title.text = saved.title ?: "LyraMusic"
        artist.text = saved.artist ?: ""
        setArt(saved.art?.let { NowPlaying.artBitmap(it, 720, 0f) })

        browser = MediaBrowserCompat(this, ComponentName(this, AudioService::class.java), object : MediaBrowserCompat.ConnectionCallback() {
            override fun onConnected() {
                val b = browser ?: return
                val c = MediaControllerCompat(this@LockScreenActivity, b.sessionToken)
                controller = c
                c.registerCallback(callback)
                render(c.metadata)
                renderState(c.playbackState)
            }
        }, null)
    }

    private val callback = object : MediaControllerCompat.Callback() {
        override fun onMetadataChanged(metadata: MediaMetadataCompat?) = render(metadata)
        override fun onPlaybackStateChanged(state: PlaybackStateCompat?) = renderState(state)
    }

    override fun onStart() {
        super.onStart()
        runCatching { browser?.connect() }
        main.post(ticker)
    }

    override fun onStop() {
        super.onStop()
        main.removeCallbacks(ticker)
        controller?.unregisterCallback(callback)
        runCatching { browser?.disconnect() }
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() = dismiss()

    private fun dismiss() {
        finish()
        overridePendingTransition(0, R.anim.lock_exit)
    }

    private fun render(m: MediaMetadataCompat?) {
        if (m == null) return
        title.text = m.getString(MediaMetadataCompat.METADATA_KEY_TITLE) ?: title.text
        artist.text = m.getString(MediaMetadataCompat.METADATA_KEY_ARTIST) ?: artist.text
        val duration = m.getLong(MediaMetadataCompat.METADATA_KEY_DURATION)
        total.text = format(duration)
        progress.max = duration.coerceAtLeast(1).toInt()
        val bitmap = m.getBitmap(MediaMetadataCompat.METADATA_KEY_ALBUM_ART)
            ?: m.getBitmap(MediaMetadataCompat.METADATA_KEY_DISPLAY_ICON)
            ?: m.getString(MediaMetadataCompat.METADATA_KEY_ART_URI)?.let { uri ->
                val path = android.net.Uri.parse(uri).path
                if (path == lastArt) return@let null
                BitmapFactory.decodeFile(path)
            }
        if (bitmap != null) setArt(bitmap)
    }

    private fun setArt(bitmap: Bitmap?) {
        if (bitmap == null) {
            art.setImageResource(R.drawable.lock_art_placeholder)
            background.setImageDrawable(null)
            return
        }
        lastArt = bitmap
        art.setImageBitmap(bitmap)
        background.setImageBitmap(bitmap)
    }

    private fun renderState(s: PlaybackStateCompat?) {
        val playing = s?.state == PlaybackStateCompat.STATE_PLAYING
        play.setImageResource(if (playing) R.drawable.ic_w_pause else R.drawable.ic_w_play)
        play.contentDescription = getString(if (playing) R.string.pause else R.string.play)
        tick()
    }

    private val ticker = object : Runnable {
        override fun run() {
            tick()
            main.postDelayed(this, 500)
        }
    }

    private fun tick() {
        val s = controller?.playbackState ?: return
        var pos = s.position
        if (s.state == PlaybackStateCompat.STATE_PLAYING) {
            pos += ((SystemClock.elapsedRealtime() - s.lastPositionUpdateTime) * s.playbackSpeed).toLong()
        }
        pos = pos.coerceIn(0, progress.max.toLong())
        progress.progress = pos.toInt()
        elapsed.text = format(pos)
    }

    private fun format(ms: Long): String {
        val s = ms / 1000
        return "%d:%02d".format(s / 60, s % 60)
    }
}
