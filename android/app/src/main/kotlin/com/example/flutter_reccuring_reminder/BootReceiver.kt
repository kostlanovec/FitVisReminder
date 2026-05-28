package com.example.flutter_reccuring_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Fired by Android after device reboot or app update.
 * Starts a minimal Flutter engine and calls the Dart [rescheduleNextBatch]
 * entry-point so notifications are restored without the user opening the app.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_MY_PACKAGE_REPLACED
        ) return

        try {
            val loader = FlutterInjector.instance().flutterLoader()
            if (!loader.initialized()) {
                loader.startInitialization(context.applicationContext)
                loader.ensureInitializationComplete(context.applicationContext, null)
            }

            val engine = FlutterEngine(context.applicationContext)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    loader.findAppBundlePath(),
                    "rescheduleNextBatch"
                )
            )
            // The engine is intentionally not cached — it will be GC'd once
            // the Dart isolate exits after completing rescheduleNextBatch().
        } catch (e: Exception) {
            // Silent — background reschedule is best-effort
        }
    }
}
