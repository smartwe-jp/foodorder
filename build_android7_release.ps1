param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm dart run tool/variant.dart build-apk android7 --env prod --release @FlutterArgs
exit $LASTEXITCODE
