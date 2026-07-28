param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm dart run tool/variant.dart run windows --env dev @FlutterArgs
exit $LASTEXITCODE
