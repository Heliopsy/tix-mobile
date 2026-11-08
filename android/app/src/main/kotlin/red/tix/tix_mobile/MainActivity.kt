package red.tix.tix_mobile

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// tix/share holds the latest text shared to the app until Dart takes it, so
// a share made before Dart listens is not lost.
//
// red.tix/local_access: shared storage for databases opened in place. The
// permission it needs is declared only by the allFilesAccess manifest
// overlay (see build.gradle.kts), so "declared" tells the app whether this
// build may offer open in place at all.
class MainActivity : FlutterActivity() {
    private var pending: Map<String, String>? = null
    private var channel: MethodChannel? = null
    private var permission: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        channel = MethodChannel(messenger, "tix/share").apply {
            setMethodCallHandler { call, result ->
                if (call.method == "take") {
                    result.success(pending)
                    pending = null
                } else {
                    result.notImplemented()
                }
            }
        }
        MethodChannel(messenger, "red.tix/local_access").setMethodCallHandler { call, result ->
            when (call.method) {
                "declared" -> result.success(declared())
                "granted" -> result.success(granted())
                "request" -> request(result)
                "root" -> result.success(Environment.getExternalStorageDirectory().absolutePath)
                else -> result.notImplemented()
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

    private fun needed(): String =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Manifest.permission.MANAGE_EXTERNAL_STORAGE
        } else {
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        }

    private fun declared(): Boolean {
        val info = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
        return info.requestedPermissions?.contains(needed()) == true
    }

    private fun granted(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
                PackageManager.PERMISSION_GRANTED
        }

    private fun request(result: MethodChannel.Result) {
        if (granted()) {
            result.success(true)
            return
        }
        if (!declared()) {
            result.success(false)
            return
        }
        permission?.success(false)
        permission = result
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val forApp = Intent(
                Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                Uri.parse("package:$packageName"),
            )
            try {
                startActivityForResult(forApp, REQUEST_FILES)
            } catch (e: ActivityNotFoundException) {
                startActivityForResult(
                    Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION),
                    REQUEST_FILES,
                )
            }
        } else {
            requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), REQUEST_FILES)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_FILES) answer()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_FILES) answer()
    }

    private fun answer() {
        permission?.success(granted())
        permission = null
    }

    private companion object {
        const val REQUEST_FILES = 4711
    }
}
