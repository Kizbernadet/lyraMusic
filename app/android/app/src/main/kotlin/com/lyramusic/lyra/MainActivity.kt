package com.lyramusic.lyra

import android.app.Activity
import android.app.PendingIntent
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Intent
import android.database.ContentObserver
import android.net.Uri
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

/**
 * Activité principale. Hérite d'AudioServiceActivity (lecture en arrière-plan)
 * et expose le canal "lyra/media" : interrogation de MediaStore, écriture
 * des fichiers audio modifiés (tags) et suppression, avec l'autorisation de l'utilisateur.
 */
class MainActivity : AudioServiceActivity() {
    private val channelName = "lyra/media"
    private val writeRequestCode = 4201
    private val deleteRequestCode = 4202
    private var pendingWrite: MethodChannel.Result? = null
    private var pendingDelete: MethodChannel.Result? = null
    private val main = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        SystemChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "lyra/media/changes")
            .setStreamHandler(MediaWatcher(applicationContext, main))
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sdkInt" -> result.success(Build.VERSION.SDK_INT)
                    "queryAudio" -> background(result) { queryAudio() }
                    "requestWrite" -> {
                        val ids = call.argument<List<Number>>("ids")!!.map { it.toLong() }
                        requestWrite(ids, result)
                    }
                    "writeFromFile" -> {
                        val id = call.argument<Number>("id")!!.toLong()
                        val source = call.argument<String>("source")!!
                        val path = call.argument<String>("path")
                        background(result) { writeFromFile(id, source, path) }
                    }
                    "deleteAudio" -> {
                        val ids = call.argument<List<Number>>("ids")!!.map { it.toLong() }
                        val paths = call.argument<List<String>>("paths")!!
                        val trash = call.argument<Boolean>("trash") ?: false
                        deleteAudio(ids, paths, trash, result)
                    }
                    "restoreAudio" -> {
                        val ids = call.argument<List<Number>>("ids")!!.map { it.toLong() }
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                            result.success(false)
                        } else {
                            mediaRequest(ids, result) { MediaStore.createTrashRequest(contentResolver, it, false) }
                        }
                    }
                    "queryTrash" -> background(result) { queryTrash() }
                    "audioEnvelope" -> {
                        val path = call.argument<String>("path")!!
                        background(result) { AudioEnvelope.compute(path) }
                    }
                    "saveImage" -> {
                        val png = call.argument<ByteArray>("png")!!
                        val name = call.argument<String>("name")!!
                        background(result) { CardExport.save(this, png, name) }
                    }
                    "shareImage" -> {
                        val png = call.argument<ByteArray>("png")!!
                        val name = call.argument<String>("name")!!
                        val title = call.argument<String>("title")
                        background(result) {
                            val intent = CardExport.shareIntent(this, png, name, title)
                            main.post { startActivity(intent) }
                            true
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun background(result: MethodChannel.Result, block: () -> Any?) {
        Thread {
            try {
                val value = block()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error(e.javaClass.simpleName, e.message, null) }
            }
        }.start()
    }

    private fun queryAudio(): List<Map<String, Any?>> {
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATE_ADDED,
            MediaStore.Audio.Media.DATE_MODIFIED,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.MIME_TYPE,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
        )
        // IS_MUSIC exclut sonneries, notifications et enregistrements vocaux.
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val rows = ArrayList<Map<String, Any?>>()
        contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, projection, selection, null, null
        )?.use { c ->
            while (c.moveToNext()) {
                rows.add(
                    mapOf(
                        "id" to c.getLong(0),
                        "path" to c.getString(1),
                        "size" to c.getLong(2),
                        "dateAdded" to c.getLong(3),
                        "dateModified" to c.getLong(4),
                        "duration" to c.getLong(5),
                        "mime" to c.getString(6),
                        "title" to c.getString(7),
                        "artist" to c.getString(8),
                        "album" to c.getString(9),
                    )
                )
            }
        }
        return rows
    }

    private fun requestWrite(ids: List<Long>, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(true)
            return
        }
        if (pendingWrite != null) {
            result.error("busy", "A write request is already pending", null)
            return
        }
        try {
            val uris = ids.map {
                ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, it)
            }
            val intent = MediaStore.createWriteRequest(contentResolver, uris)
            pendingWrite = result
            startIntentSenderForResult(intent.intentSender, writeRequestCode, null, 0, 0, 0)
        } catch (e: Exception) {
            pendingWrite = null
            result.error(e.javaClass.simpleName, e.message, null)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == writeRequestCode) {
            pendingWrite?.success(resultCode == Activity.RESULT_OK)
            pendingWrite = null
            return
        }
        if (requestCode == deleteRequestCode) {
            pendingDelete?.success(resultCode == Activity.RESULT_OK)
            pendingDelete = null
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    /**
     * Supprime des fichiers audio.
     * Android 11+ : demande système, puis le système agit lui-même si l'utilisateur
     * accepte. Avec [trash], les fichiers vont dans la corbeille du téléphone
     * (restaurables pendant 30 jours) ; sinon ils sont supprimés définitivement.
     * Android 10 et inférieur : pas de corbeille, suppression directe (stockage hérité).
     */
    private fun deleteAudio(ids: List<Long>, paths: List<String>, trash: Boolean, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            mediaRequest(ids, result) {
                if (trash) MediaStore.createTrashRequest(contentResolver, it, true)
                else MediaStore.createDeleteRequest(contentResolver, it)
            }
            return
        }
        background(result) {
            var ok = true
            ids.forEachIndexed { i, id ->
                val uri = ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
                val file = paths.getOrNull(i)?.let { File(it) }
                try {
                    if (file != null && file.exists()) file.delete()
                    contentResolver.delete(uri, null, null)
                } catch (_: Exception) {
                }
                if (file != null && file.exists()) ok = false
            }
            if (!ok) throw IllegalStateException("Some files could not be deleted")
            true
        }
    }

    /** Affiche une demande système MediaStore (Android 11+) ; true si l'utilisateur accepte. */
    private fun mediaRequest(ids: List<Long>, result: MethodChannel.Result, build: (List<Uri>) -> PendingIntent) {
        if (pendingDelete != null) {
            result.error("busy", "A request is already pending", null)
            return
        }
        try {
            val uris = ids.map { ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, it) }
            val intent = build(uris)
            pendingDelete = result
            startIntentSenderForResult(intent.intentSender, deleteRequestCode, null, 0, 0, 0)
        } catch (e: Exception) {
            pendingDelete = null
            result.error(e.javaClass.simpleName, e.message, null)
        }
    }

    /** Morceaux dans la corbeille du téléphone (Android 11+). */
    private fun queryTrash(): List<Map<String, Any?>> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return emptyList()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATE_EXPIRES,
        )
        val args = Bundle().apply {
            putInt(MediaStore.QUERY_ARG_MATCH_TRASHED, MediaStore.MATCH_ONLY)
            putString(ContentResolver.QUERY_ARG_SQL_SELECTION, "${MediaStore.Audio.Media.IS_MUSIC} != 0")
        }
        val rows = ArrayList<Map<String, Any?>>()
        contentResolver.query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, projection, args, null)?.use { c ->
            while (c.moveToNext()) {
                rows.add(
                    mapOf(
                        "id" to c.getLong(0),
                        "path" to c.getString(1),
                        "title" to c.getString(2),
                        "artist" to c.getString(3),
                        "duration" to c.getLong(4),
                        "expires" to c.getLong(5),
                    )
                )
            }
        }
        return rows
    }

    /** Remplace le contenu du fichier audio [id] par celui de [source]. */
    private fun writeFromFile(id: Long, source: String, path: String?): Boolean {
        val uri = ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
        val src = File(source)
        val pfd = contentResolver.openFileDescriptor(uri, "rwt")
            ?: throw IllegalStateException("Cannot open $uri")
        pfd.use { fd ->
            FileOutputStream(fd.fileDescriptor).use { out ->
                FileInputStream(src).use { input -> input.copyTo(out, 1 shl 16) }
                out.flush()
                // Certains fournisseurs ignorent le "t" de "rwt" : on tronque explicitement.
                out.channel.truncate(src.length())
                out.fd.sync()
            }
        }
        if (path != null) {
            MediaScannerConnection.scanFile(this, arrayOf(path), null, null)
        }
        return true
    }
}

/**
 * Prévient Flutter quand MediaStore change (fichier audio ajouté, supprimé ou modifié).
 * Les notifications arrivent souvent en rafale (copie de dossier) : on attend
 * un court moment de calme avant d'envoyer un seul événement.
 */
private class MediaWatcher(
    private val context: android.content.Context,
    private val main: Handler,
) : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null
    private val emit = Runnable { sink?.success(null) }
    private val observer = object : ContentObserver(main) {
        override fun onChange(selfChange: Boolean, uri: Uri?) {
            main.removeCallbacks(emit)
            main.postDelayed(emit, 1500)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
        context.contentResolver.registerContentObserver(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, true, observer
        )
    }

    override fun onCancel(arguments: Any?) {
        context.contentResolver.unregisterContentObserver(observer)
        main.removeCallbacks(emit)
        sink = null
    }
}
