# foodorder

A new Fanxing Food Order Flutter project.

## Run variants

The dependency set and API environment are selected at compile time. Do not
temporarily edit `pubspec.yaml`, `machineType`, or `isProduction`.

macOS/Linux:

```bash
# Android 7: paycube_old
./run_android7_dev -d <device-id>
./run_android7_release -d <device-id>

# Android 11+: paycube
./run_android11_dev -d <device-id>
./run_android11_release -d <device-id>

# Windows: no PayCube dependency
./run_windows_dev -d windows
./run_windows_release -d windows
```

Windows PowerShell:

```powershell
.\run_windows_dev.ps1 -d windows
.\run_windows_release.ps1 -d windows
```

- `*_dev`: development API (`https://sit-api.smartwe.jp/`) and Flutter debug.
- `*_release`: production API (`https://api.smartwe.jp/`) and Flutter release.
- Extra arguments such as `-d`, `--verbose`, and `--device-timeout` are
  forwarded to `flutter run`.

The runner temporarily activates the matching file under `variants/`, uses its
lock file, and restores the original `pubspec.yaml`, lock file, and generated
plugin files after Flutter exits (including Ctrl+C).

When changing common dependencies, apply the same change to all three manifests
and regenerate their lock files:

```bash
fvm dart run tool/variant.dart resolve android7
fvm dart run tool/variant.dart resolve android11
fvm dart run tool/variant.dart resolve windows
```

If a run was force-killed before cleanup completed, restore the original files:

```bash
fvm dart run tool/variant.dart restore
```

For a local variant build without editing manifests manually:

```bash
./build_android7_release
./build_android11_release
./build_windows_release
```

On Windows PowerShell, use the matching `.ps1` file. Android APKs are preserved
under `build/releases/` with version and platform suffixes. The Windows build
output remains under `build/windows/x64/runner/Release/`.

The legacy `run_dev` and `run_release` scripts remain Windows aliases. Use the
variant scripts for dependency-safe launches; direct VS Code Flutter launches
do not switch manifests.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
