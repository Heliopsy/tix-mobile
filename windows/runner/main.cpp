#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <string>
#include <vector>

#include "flutter_window.h"
#include "utils.h"

namespace {

BOOL CALLBACK FindTixWindow(HWND hwnd, LPARAM found) {
  if (GetPropW(hwnd, kTixWindowProperty) == nullptr) {
    return TRUE;
  }
  *reinterpret_cast<HWND*>(found) = hwnd;
  return FALSE;
}

// tix runs once per session. A second launch hands its tix:// link (or
// nothing) to the running window, lets it take the foreground, and leaves.
bool HandedToRunningTix(const std::string& link) {
  HWND running = nullptr;
  EnumWindows(FindTixWindow, reinterpret_cast<LPARAM>(&running));
  if (running == nullptr) {
    return false;
  }
  DWORD process = 0;
  GetWindowThreadProcessId(running, &process);
  AllowSetForegroundWindow(process);
  COPYDATASTRUCT data{kTixActivate, static_cast<DWORD>(link.size()),
                      const_cast<char*>(link.data())};
  SendMessageW(running, WM_COPYDATA, 0, reinterpret_cast<LPARAM>(&data));
  return true;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  bool background = false;
  std::string link;
  for (const std::string& argument : command_line_arguments) {
    if (argument == "--background") {
      background = true;
    } else if (link.empty() && argument.rfind("tix:", 0) == 0) {
      link = argument;
    }
  }

  // Held until the process ends; only its existence matters.
  CreateMutexW(nullptr, FALSE, L"Local\\red.tix.tix_mobile");
  if (GetLastError() == ERROR_ALREADY_EXISTS &&
      ((background && link.empty()) || HandedToRunningTix(link))) {
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project, background, link);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"tix", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
