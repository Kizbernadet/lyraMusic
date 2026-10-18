package com.lyramusic.lyra

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream

/**
 * Export des LyricsCards : l'image est rendue par Flutter (PNG sans perte),
 * puis encodée ici en JPEG haute qualité.
 */
object CardExport {
    private const val QUALITY = 95
    private const val FOLDER = "LyraMusic"

    private fun encode(png: ByteArray, out: OutputStream) {
        val bitmap = BitmapFactory.decodeByteArray(png, 0, png.size)
            ?: throw IllegalArgumentException("Invalid image")
        try {
            bitmap.compress(Bitmap.CompressFormat.JPEG, QUALITY, out)
        } finally {
            bitmap.recycle()
        }
    }

    /** Enregistre dans la galerie (Images/LyraMusic). Renvoie l'URI de l'image. */
    fun save(context: Context, png: ByteArray, name: String): String {
        val file = "$name.jpg"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = context.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, file)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(MediaStore.Images.Media.RELATIVE_PATH, "${Environment.DIRECTORY_PICTURES}/$FOLDER")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("MediaStore insert failed")
            try {
                resolver.openOutputStream(uri)!!.use { encode(png, it) }
                values.clear()
                values.put(MediaStore.Images.Media.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
            } catch (e: Exception) {
                resolver.delete(uri, null, null)
                throw e
            }
            return uri.toString()
        }
        // Android 9 et inférieur : écriture directe (permission demandée côté Flutter).
        @Suppress("DEPRECATION")
        val dir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), FOLDER)
        dir.mkdirs()
        val target = File(dir, file)
        FileOutputStream(target).use { encode(png, it) }
        MediaScannerConnection.scanFile(context, arrayOf(target.path), arrayOf("image/jpeg"), null)
        return target.path
    }

    /** Feuille de partage du système, à partir d'une copie JPEG dans le cache. */
    fun shareIntent(context: Context, png: ByteArray, name: String, title: String?): Intent {
        val dir = File(context.cacheDir, "cards").apply { mkdirs() }
        dir.listFiles()?.forEach { it.delete() } // une seule carte en cache à la fois
        val target = File(dir, "$name.jpg")
        FileOutputStream(target).use { encode(png, it) }
        val uri = FileProvider.getUriForFile(context, "${context.packageName}.cards", target)
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "image/jpeg"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        return Intent.createChooser(send, title).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
    }
}
