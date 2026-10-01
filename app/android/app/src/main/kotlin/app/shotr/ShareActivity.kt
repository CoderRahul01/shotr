package app.shotr

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode

/**
 * Share receiver. Opens over whatever app the user is in (X, LinkedIn, Gallery, anywhere),
 * shows the shotr sheet on a transparent window, and finishes back to that app on Save.
 * The Flutter side starts on the /share route (see lib/main.dart).
 */
class ShareActivity : FlutterActivity() {
    override fun getInitialRoute(): String = "/share"

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent
}
