package com.example.agrigo

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.provider.MediaStore
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "agrigo/native_save"
	private val NOTIF_CHANNEL_ID = "agrigo_downloads"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		// Create notification channel
		createNotificationChannel()

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"saveToDownloads" -> {
					val filename = call.argument<String>("filename") ?: "file.dat"
					val mime = call.argument<String>("mime") ?: "application/octet-stream"
					val bytes = call.argument<ByteArray>("bytes")
					if (bytes == null) {
						result.error("NO_BYTES", "No bytes provided", null)
						return@setMethodCallHandler
					}
					try {
						showProgressNotification("Mengunduh $filename...")
						val uri = saveBytesToDownloads(this, filename, mime, bytes)
						showCompletedNotification("Unduhan selesai", filename)
						result.success(uri.toString())
					} catch (e: Exception) {
						result.error("SAVE_ERROR", e.message, null)
					}
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun createNotificationChannel() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			val name = "Unduhan Agrigo"
			val descriptionText = "Notifikasi unduhan Agrigo"
			val importance = NotificationManager.IMPORTANCE_DEFAULT
			val channel = NotificationChannel(NOTIF_CHANNEL_ID, name, importance)
			channel.description = descriptionText
			val notificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
			notificationManager.createNotificationChannel(channel)
		}
	}

	private fun showProgressNotification(text: String) {
		val builder = NotificationCompat.Builder(this, NOTIF_CHANNEL_ID)
			.setSmallIcon(android.R.drawable.stat_sys_download)
			.setContentTitle("Mengunduh")
			.setContentText(text)
			.setOngoing(true)
		val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
		nm.notify(1001, builder.build())
	}

	private fun showCompletedNotification(title: String, filename: String) {
		val builder = NotificationCompat.Builder(this, NOTIF_CHANNEL_ID)
			.setSmallIcon(android.R.drawable.stat_sys_download_done)
			.setContentTitle(title)
			.setContentText(filename)
			.setAutoCancel(true)
		val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
		nm.notify(1001, builder.build())
	}

	private fun saveBytesToDownloads(context: Context, displayName: String, mimeType: String, bytes: ByteArray): android.net.Uri {
		val resolver = context.contentResolver
		val values = ContentValues().apply {
			put(MediaStore.Downloads.DISPLAY_NAME, displayName)
			put(MediaStore.Downloads.MIME_TYPE, mimeType)
			put(MediaStore.Downloads.IS_PENDING, 1)
		}

		val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
			MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
		} else {
			MediaStore.Files.getContentUri("external")
		}

		val itemUri = resolver.insert(collection, values) ?: throw Exception("Unable to create MediaStore entry")

		resolver.openOutputStream(itemUri).use { out ->
			out?.write(bytes)
			out?.flush()
		}

		values.clear()
		values.put(MediaStore.Downloads.IS_PENDING, 0)
		resolver.update(itemUri, values, null, null)

		return itemUri
	}
}
