param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm dart run tool/variant.dart build-apk android11 --env prod --release @FlutterArgs
exit $LASTEXITCODE
