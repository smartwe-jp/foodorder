param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm flutter run -t lib/main.dart --release --dart-define=APP_ENV=prod @FlutterArgs
exit $LASTEXITCODE
