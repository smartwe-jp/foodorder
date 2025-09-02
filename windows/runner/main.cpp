#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // ---------------------------------------------------------------------------
  // Single instance guard: create a named mutex. If it already exists, try to
  // activate the existing window then exit immediately.
  // ---------------------------------------------------------------------------
  const wchar_t kMutexName[] = L"Global\\Foodorder_SingleInstance_Mutex"; // use Global so TS sessions share
  HANDLE hMutex = ::CreateMutexW(nullptr, FALSE, kMutexName);
  if (hMutex && ::GetLastError() == ERROR_ALREADY_EXISTS) {
    // Try find existing window by class name first (from win32_window.cpp)
    HWND hwnd = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", nullptr);
    if (!hwnd) {
      // Fallback: search by expected window title
      hwnd = ::FindWindowW(nullptr, L"foodorder");
    }
    if (hwnd) {
      ::ShowWindow(hwnd, SW_RESTORE);
      ::SetForegroundWindow(hwnd);
    }
    if (hMutex) ::CloseHandle(hMutex);
    return EXIT_SUCCESS; // Do not treat as error; user just launched second instance.
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

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"foodorder", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  if (hMutex) {
    ::CloseHandle(hMutex);
  }
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
