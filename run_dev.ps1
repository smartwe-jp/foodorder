param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& "$PSScriptRoot\run_windows_dev.ps1" @FlutterArgs
exit $LASTEXITCODE
