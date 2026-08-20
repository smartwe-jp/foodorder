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

`pubspec.yaml` is the single source of truth for version, dependencies, assets,
fonts, and other platform-independent configuration. The files under
`variants/` are small overlays that select only `paycube_old`, `paycube`, or no
PayCube dependency. The runner composes the selected manifest at build time,
uses its lock file, and restores the original `pubspec.yaml`, lock file, and
generated plugin files after Flutter exits (including Ctrl+C).

When changing a common dependency, edit only `pubspec.yaml`, then regenerate
the lock files for all variants:

```bash
fvm dart run tool/variant.dart resolve android7
fvm dart run tool/variant.dart resolve android11
fvm dart run tool/variant.dart resolve windows
```

When changing a platform-specific PayCube path, edit only the matching overlay
under `variants/`, then resolve that variant.

If a run was force-killed before cleanup completed, restore the original files:

```bash
fvm dart run tool/variant.dart restore
```
// build dev
fvm dart run tool/variant.dart build-windows windows --env dev --release
fvm dart run tool/variant.dart build-apk android7 --env dev --release
fvm dart run tool/variant.dart build-apk android11 --env dev --release

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
