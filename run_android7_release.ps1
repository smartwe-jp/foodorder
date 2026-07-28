param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm dart run tool/variant.dart run android7 --env prod --release @FlutterArgs
exit $LASTEXITCODE
