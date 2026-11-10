import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func awakeFromNib() {
    super.awakeFromNib()
    addApplicationLifecycleDelegate(WidgetChannel.shared)
    addApplicationLifecycleDelegate(DesktopChannel.shared)
  }

  // A click on the Dock icon brings back a window hidden to the menu bar.
  override func applicationShouldHandleReopen(
    _ sender: NSApplication, hasVisibleWindows flag: Bool
  ) -> Bool {
    if !flag { DesktopChannel.shared.showWindow() }
    return true
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
