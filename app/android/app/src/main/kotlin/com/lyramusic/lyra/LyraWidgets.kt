package com.lyramusic.lyra

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.support.v4.media.session.PlaybackStateCompat
import android.view.View
import android.widget.RemoteViews
import androidx.media.session.MediaButtonReceiver

/** Widget compact 4 × 1 : pochette, titre, précédent / lecture / suivant. */
class LyraWidgetSmall : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) =
        LyraWidgets.update(context, manager, ids, R.layout.widget_small, NowPlaying.load(context))
}

/** Grand widget 4 × 2 : grande pochette et commandes. */
class LyraWidgetLarge : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) =
        LyraWidgets.update(context, manager, ids, R.layout.widget_large, NowPlaying.load(context))
}

object LyraWidgets {
    fun updateAll(ctx: Context, state: NowPlaying.State) {
        val m = AppWidgetManager.getInstance(ctx)
        update(ctx, m, m.getAppWidgetIds(ComponentName(ctx, LyraWidgetSmall::class.java)), R.layout.widget_small, state)
        update(ctx, m, m.getAppWidgetIds(ComponentName(ctx, LyraWidgetLarge::class.java)), R.layout.widget_large, state)
    }

    fun update(ctx: Context, manager: AppWidgetManager, ids: IntArray, layout: Int, s: NowPlaying.State) {
        if (ids.isEmpty()) return
        val large = layout == R.layout.widget_large
        val views = RemoteViews(ctx.packageName, layout)
        views.setTextViewText(R.id.widget_title, s.title ?: ctx.getString(R.string.widget_idle_title))
        views.setTextViewText(R.id.widget_artist, s.artist ?: ctx.getString(R.string.widget_idle_subtitle))
        val art = NowPlaying.artBitmap(s.art, if (large) 320 else 160, 0.14f)
        if (art != null) {
            views.setImageViewBitmap(R.id.widget_art, art)
            views.setViewVisibility(R.id.widget_art_placeholder, View.GONE)
        } else {
            views.setImageViewResource(R.id.widget_art, R.drawable.widget_art_bg)
            views.setViewVisibility(R.id.widget_art_placeholder, View.VISIBLE)
        }
        views.setImageViewResource(R.id.widget_play, if (s.playing) R.drawable.ic_w_pause else R.drawable.ic_w_play)
        views.setContentDescription(R.id.widget_play, ctx.getString(if (s.playing) R.string.pause else R.string.play))

        val receiver = ComponentName(ctx, com.ryanheise.audioservice.MediaButtonReceiver::class.java)
        fun media(action: Long) = MediaButtonReceiver.buildMediaButtonPendingIntent(ctx, receiver, action)
        views.setOnClickPendingIntent(R.id.widget_play, media(PlaybackStateCompat.ACTION_PLAY_PAUSE))
        views.setOnClickPendingIntent(R.id.widget_prev, media(PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS))
        views.setOnClickPendingIntent(R.id.widget_next, media(PlaybackStateCompat.ACTION_SKIP_TO_NEXT))
        val open = PendingIntent.getActivity(
            ctx, 1,
            Intent(ctx, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        views.setOnClickPendingIntent(R.id.widget_root, open)
        manager.updateAppWidget(ids, views)
    }

    /** Demande au lanceur d'ajouter un widget (Android 8+, si le lanceur le permet). */
    fun pin(ctx: Context, kind: String): Boolean {
        val m = AppWidgetManager.getInstance(ctx)
        if (!m.isRequestPinAppWidgetSupported) return false
        val cls = if (kind == "large") LyraWidgetLarge::class.java else LyraWidgetSmall::class.java
        return m.requestPinAppWidget(ComponentName(ctx, cls), null, null)
    }
}
