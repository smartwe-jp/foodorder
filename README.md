# foodorder

A new Fanxing Food Order Flutter project.

## Run environments

The API environment is selected at compile time with `APP_ENV`. Do not edit
`isProduction` in source code.

macOS/Linux:

```bash
./run_dev -d <device-id>
./run_release -d <device-id>
```

Windows PowerShell:

```powershell
.\run_dev.ps1 -d windows
.\run_release.ps1 -d windows
```

- `run_dev`: development API (`https://sit-api.smartwe.jp/`) with Flutter debug mode.
- `run_release`: production API (`https://api.smartwe.jp/`) with Flutter release mode.
- Extra arguments are forwarded to `flutter run`.

VS Code also provides `Flutter Dev` and `Flutter Production (Release)` launch
configurations.

Direct commands must explicitly provide one of:

```bash
fvm flutter run -t lib/main.dart --dart-define=APP_ENV=dev
fvm flutter run -t lib/main.dart --release --dart-define=APP_ENV=prod
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
