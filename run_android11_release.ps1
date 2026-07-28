param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm dart run tool/variant.dart run android11 --env prod --release @FlutterArgs
exit $LASTEXITCODE
