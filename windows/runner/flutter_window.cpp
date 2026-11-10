#include "flutter_window.h"

#include <flutter/standard_method_codec.h>

#include <optional>
#include <utility>
#include <variant>

#include "flutter/generated_plugin_registrant.h"

namespace {

constexpr int kHotkeyId = 1;
constexpr wchar_t kRunKey[] =
    L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
constexpr wchar_t kRunValue[] = L"red.tix.tix_mobile";

bool AutostartOn() {
  return RegGetValueW(HKEY_CURRENT_USER, kRunKey, kRunValue, RRF_RT_REG_SZ,
                      nullptr, nullptr, nullptr) == ERROR_SUCCESS;
}

// Start at login is a value under the user's Run key that starts this
// executable hidden.
bool SetAutostart(bool on) {
  if (!on) {
    LSTATUS status =
        RegDeleteKeyValueW(HKEY_CURRENT_USER, kRunKey, kRunValue);
    return status == ERROR_SUCCESS || status == ERROR_FILE_NOT_FOUND;
  }
  wchar_t path[MAX_PATH];
  DWORD length = GetModuleFileNameW(nullptr, path, MAX_PATH);
  if (length == 0 || length == MAX_PATH) {
    return false;
  }
  std::wstring command = L"\"" + std::wstring(path) + L"\" --background";
  return RegSetKeyValueW(
             HKEY_CURRENT_USER, kRunKey, kRunValue, REG_SZ, command.c_str(),
             static_cast<DWORD>((command.size() + 1) * sizeof(wchar_t))) ==
         ERROR_SUCCESS;
}

bool BoolArgument(const flutter::MethodCall<>& call) {
  const auto* on = std::get_if<bool>(call.arguments());
  return on != nullptr && *on;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project,
                             bool background, std::string link)
    : project_(project),
      background_(background),
      pending_link_(std::move(link)) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  SetPropW(GetHandle(), kTixWindowProperty, reinterpret_cast<HANDLE>(1));

  auto* messenger = flutter_controller_->engine()->messenger();
  const auto* codec = &flutter::StandardMethodCodec::GetInstance();
  links_ = std::make_unique<flutter::MethodChannel<>>(messenger, "tix/links",
                                                      codec);
  links_->SetMethodCallHandler([this](const auto& call, auto result) {
    if (call.method_name() != "take") {
      result->NotImplemented();
      return;
    }
    listening_ = true;
    if (pending_link_.empty()) {
      result->Success();
      return;
    }
    result->Success(flutter::EncodableValue(pending_link_));
    pending_link_.clear();
  });
  desktop_ = std::make_unique<flutter::MethodChannel<>>(
      messenger, "tix/desktop", codec);
  desktop_->SetMethodCallHandler([this](const auto& call, auto result) {
    const std::string& method = call.method_name();
    if (method == "capabilities") {
      result->Success(flutter::EncodableValue(flutter::EncodableMap{
          {flutter::EncodableValue("tray"), flutter::EncodableValue(true)},
          {flutter::EncodableValue("autostart"), flutter::EncodableValue(true)},
          {flutter::EncodableValue("hotkey"), flutter::EncodableValue(true)},
          {flutter::EncodableValue("background"),
           flutter::EncodableValue(background_)},
      }));
    } else if (method == "autostart") {
      result->Success(flutter::EncodableValue(AutostartOn()));
    } else if (method == "setAutostart") {
      result->Success(flutter::EncodableValue(SetAutostart(BoolArgument(call))));
    } else if (method == "setHotkey") {
      result->Success(flutter::EncodableValue(SetHotkey(BoolArgument(call))));
    } else {
      result->NotImplemented();
    }
  });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    if (!background_) {
      this->Show();
    }
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  SetHotkey(false);
  RemovePropW(GetHandle(), kTixWindowProperty);
  links_ = nullptr;
  desktop_ = nullptr;
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::Activate(const std::string& link) {
  HWND hwnd = GetHandle();
  ShowWindow(hwnd, IsIconic(hwnd) ? SW_RESTORE : SW_SHOW);
  SetForegroundWindow(hwnd);
  if (!link.empty()) {
    OpenLink(link);
  }
}

void FlutterWindow::OpenLink(const std::string& link) {
  pending_link_ = link;
  if (listening_ && links_) {
    links_->InvokeMethod("opened", nullptr);
  }
}

bool FlutterWindow::SetHotkey(bool on) {
  if (on == hotkey_) {
    return true;
  }
  if (!on) {
    UnregisterHotKey(GetHandle(), kHotkeyId);
    hotkey_ = false;
    return true;
  }
  hotkey_ = RegisterHotKey(GetHandle(), kHotkeyId,
                           MOD_CONTROL | MOD_SHIFT | MOD_NOREPEAT,
                           VK_SPACE) != FALSE;
  return hotkey_;
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    case WM_COPYDATA: {
      const auto* data = reinterpret_cast<const COPYDATASTRUCT*>(lparam);
      if (data != nullptr && data->dwData == kTixActivate) {
        Activate(data->cbData == 0
                     ? std::string()
                     : std::string(static_cast<const char*>(data->lpData),
                                   data->cbData));
        return TRUE;
      }
      break;
    }
    case WM_HOTKEY:
      if (wparam == static_cast<WPARAM>(kHotkeyId) && desktop_) {
        desktop_->InvokeMethod("hotkey", nullptr);
        return 0;
      }
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
