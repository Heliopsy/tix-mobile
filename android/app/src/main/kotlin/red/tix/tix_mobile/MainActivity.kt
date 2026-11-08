package red.tix.tix_mobile

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// Holds the latest text shared to the app until Dart takes it over the
// tix/share channel, so a share made before Dart listens is not lost.
class MainActivity : FlutterActivity() {
    private var pending: Map<String, String>? = null
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tix/share").apply {
            setMethodCallHandler { call, result ->
                if (call.method == "take") {
                    result.success(pending)
                    pending = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (savedInstanceState == null) keep(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (keep(intent)) channel?.invokeMethod("shared", null)
    }

    private fun keep(intent: Intent?): Boolean {
        if (intent?.action != Intent.ACTION_SEND || intent.type?.startsWith("text/") != true) return false
        val text = intent.getStringExtra(Intent.EXTRA_TEXT).orEmpty()
        val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT).orEmpty()
        if (text.isBlank() && subject.isBlank()) return false
        pending = mapOf("text" to text, "subject" to subject)
        return true
    }
}
