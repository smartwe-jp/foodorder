$clientConfig = if ($env:OPENOBSERVE_CLIENT_CONFIG) {
    $env:OPENOBSERVE_CLIENT_CONFIG
} else {
    Join-Path $PSScriptRoot ".openobserve-client.json"
}

$monitoringArguments = @()
if (Test-Path -LiteralPath $clientConfig -PathType Leaf) {
    $resolvedConfig = (Resolve-Path -LiteralPath $clientConfig).Path
    $monitoringArguments += "--dart-define-from-file=$resolvedConfig"
} elseif ($env:OPENOBSERVE_INGEST_URL -and $env:OPENOBSERVE_INGEST_KEY) {
    $monitoringArguments += "--dart-define=OPENOBSERVE_INGEST_URL=$($env:OPENOBSERVE_INGEST_URL)"
    $monitoringArguments += "--dart-define=OPENOBSERVE_INGEST_KEY=$($env:OPENOBSERVE_INGEST_KEY)"
} else {
    Write-Error "OpenObserve client configuration was not found."
    exit 1
}

Push-Location $PSScriptRoot
try {
    & fvm dart run tool/variant.dart run windows --env prod --release @monitoringArguments @args
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
