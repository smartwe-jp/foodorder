param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm dart run tool/variant.dart run windows --env prod --release @FlutterArgs
exit $LASTEXITCODE
