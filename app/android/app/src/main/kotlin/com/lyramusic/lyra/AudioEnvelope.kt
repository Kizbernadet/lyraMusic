package com.lyramusic.lyra

import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.os.Build
import java.nio.ByteOrder
import kotlin.math.sqrt

/**
 * Enveloppe sonore d'un fichier audio : volume (RMS) toutes les 10 ms, ramené
 * entre 0 et 255. Sert à dessiner la forme d'onde dans le studio de
 * synchronisation et à repérer les attaques (début d'une ligne chantée).
 * Le fichier est décodé entièrement sur le téléphone, sans réseau.
 */
object AudioEnvelope {
    private const val FRAME_MS = 10

    fun compute(path: String): ByteArray {
        val extractor = MediaExtractor()
        var codec: MediaCodec? = null
        try {
            extractor.setDataSource(path)
            var format: MediaFormat? = null
            for (i in 0 until extractor.trackCount) {
                val f = extractor.getTrackFormat(i)
                if (f.getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true) {
                    extractor.selectTrack(i)
                    format = f
                    break
                }
            }
            if (format == null) throw IllegalStateException("No audio track")
            val decoder = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
            codec = decoder
            decoder.configure(format, null, null, 0)
            decoder.start()

            var window = window(format)
            var isFloat = false
            val frames = FloatArrayList()
            var acc = 0.0
            var count = 0
            val info = MediaCodec.BufferInfo()
            var inputDone = false
            while (true) {
                if (!inputDone) {
                    val inIdx = decoder.dequeueInputBuffer(10_000)
                    if (inIdx >= 0) {
                        val buf = decoder.getInputBuffer(inIdx)!!
                        val size = extractor.readSampleData(buf, 0)
                        if (size < 0) {
                            decoder.queueInputBuffer(inIdx, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            decoder.queueInputBuffer(inIdx, 0, size, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                val outIdx = decoder.dequeueOutputBuffer(info, 10_000)
                if (outIdx == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    val f = decoder.outputFormat
                    window = window(f)
                    isFloat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.N &&
                        f.containsKey(MediaFormat.KEY_PCM_ENCODING) &&
                        f.getInteger(MediaFormat.KEY_PCM_ENCODING) == AudioFormat.ENCODING_PCM_FLOAT
                } else if (outIdx >= 0) {
                    val out = decoder.getOutputBuffer(outIdx)!!
                    out.position(info.offset)
                    out.limit(info.offset + info.size)
                    out.order(ByteOrder.nativeOrder())
                    if (isFloat) {
                        val fb = out.asFloatBuffer()
                        while (fb.hasRemaining()) {
                            val v = fb.get()
                            acc += v * v
                            if (++count >= window) {
                                frames.add(sqrt(acc / count).toFloat()); acc = 0.0; count = 0
                            }
                        }
                    } else {
                        val sb = out.asShortBuffer()
                        while (sb.hasRemaining()) {
                            val v = sb.get() / 32768f
                            acc += v * v
                            if (++count >= window) {
                                frames.add(sqrt(acc / count).toFloat()); acc = 0.0; count = 0
                            }
                        }
                    }
                    decoder.releaseOutputBuffer(outIdx, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
                }
            }
            if (count > 0) frames.add(sqrt(acc / count).toFloat())
            return frames.normalized()
        } finally {
            try {
                codec?.stop()
            } catch (_: Exception) {
            }
            codec?.release()
            extractor.release()
        }
    }

    /** Nombre d'échantillons (tous canaux) dans 10 ms. */
    private fun window(f: MediaFormat): Int {
        val rate = f.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channels = f.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        return maxOf(1, rate * channels * FRAME_MS / 1000)
    }

    /** Liste de flottants sans objets intermédiaires (quelques dizaines de milliers de valeurs). */
    private class FloatArrayList {
        private var data = FloatArray(32_768)
        private var size = 0

        fun add(v: Float) {
            if (size == data.size) data = data.copyOf(size * 2)
            data[size++] = v
        }

        fun normalized(): ByteArray {
            var max = 0f
            for (i in 0 until size) if (data[i] > max) max = data[i]
            return ByteArray(size) { i -> if (max <= 0f) 0 else (data[i] / max * 255f).toInt().toByte() }
        }
    }
}
