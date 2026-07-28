param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& fvm dart run tool/variant.dart run android11 --env dev @FlutterArgs
exit $LASTEXITCODE
