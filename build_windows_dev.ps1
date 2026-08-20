$runnerExitCode = 1

try {
    & fvm dart run tool/variant.dart build-windows windows --env dev --release @args
    $runnerExitCode = $LASTEXITCODE
}
finally {
    & fvm dart run tool/variant.dart restore
    $restoreExitCode = $LASTEXITCODE
    if ($runnerExitCode -eq 0 -and $restoreExitCode -ne 0) {
        $runnerExitCode = $restoreExitCode
    }
}

exit $runnerExitCode
