package red.tix.tix_mobile

import android.app.Activity
import android.content.Intent
import android.os.Bundle

// Takes the red.tix.mobile:/sso redirect a provider sign-in ends with, in
// the Custom Tab MainActivity opened. Bringing MainActivity back with
// CLEAR_TOP closes the tab above it, and SINGLE_TOP hands it the redirect in
// onNewIntent, where it reaches Dart over tix/links like a tix:// link
// (lib/src/core/platform/sso_browser.dart).
class SsoCallbackActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val data = intent?.data
        if (data != null && data.scheme.equals(SCHEME, ignoreCase = true)) {
            startActivity(
                Intent(this, MainActivity::class.java)
                    .setAction(Intent.ACTION_VIEW)
                    .setData(data)
                    .addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP,
                    ),
            )
        }
        finish()
    }

    companion object {
        const val SCHEME = "red.tix.mobile"
    }
}
