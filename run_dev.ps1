param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm flutter run -t lib/main.dart --dart-define=APP_ENV=dev @FlutterArgs
exit $LASTEXITCODE
