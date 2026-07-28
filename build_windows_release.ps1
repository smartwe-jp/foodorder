param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm dart run tool/variant.dart build-windows windows --env prod --release @FlutterArgs
exit $LASTEXITCODE
