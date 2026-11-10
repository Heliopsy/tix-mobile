#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>

#include <memory>
#include <string>

#include "win32_window.h"

// WM_COPYDATA from a second launch to the running window carries this tag and
// a tix:// link in UTF-8, or nothing to just show the window.
constexpr ULONG_PTR kTixActivate = 0x74697801;

// The window property that marks tix's window among other Flutter runners,
// which share its class name.
constexpr wchar_t kTixWindowProperty[] = L"red.tix.tix_mobile";

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  // |background| keeps it hidden at first (a launch from the Run key), and
  // |link| is a tix:// link it was started with.
  FlutterWindow(const flutter::DartProject& project, bool background,
                std::string link);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // Shows and focuses the window, then hands Dart |link| if there is one.
  void Activate(const std::string& link);

  // Holds |link| for Dart to take over tix/links and tells it if listening.
  void OpenLink(const std::string& link);

  // Registers or drops Ctrl+Shift+Space; false when another app holds it.
  bool SetHotkey(bool on);

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // tix/links and tix/desktop; see lib/src/core/platform/.
  std::unique_ptr<flutter::MethodChannel<>> links_;
  std::unique_ptr<flutter::MethodChannel<>> desktop_;

  bool background_;
  std::string pending_link_;
  bool listening_ = false;
  bool hotkey_ = false;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
