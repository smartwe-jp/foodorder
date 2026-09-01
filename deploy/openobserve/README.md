# Local OpenObserve deployment

This directory starts a single-node OpenObserve OSS instance behind Nginx. It is intended for local integration and small single-server deployments.

## Services

- OpenObserve stores data in the named Docker volume `foodorder-openobserve-data`.
- Nginx exposes the UI and the restricted `/app-events` ingestion route. The old `/app-incidents` path remains as a compatible alias.
- OpenObserve port `5080` is not published directly.
- By default Nginx binds only to `127.0.0.1:5080`.

## Start

```bash
cd deploy/openobserve
./init-env.sh
docker compose config --quiet
docker compose pull
docker compose up -d
docker compose ps
```

Open <http://localhost:5080> and sign in with `OPENOBSERVE_ROOT_EMAIL` and `OPENOBSERVE_ROOT_PASSWORD` from the generated `.env` file.

Run the ingestion smoke test:

```bash
./smoke-test.sh
```

Then open Logs and select the `app_events` stream.

The App sends every structured `Logger` record (`INFO`, `WARNING`, `SEVERE`,
and other `package:logging` levels) to this stream. `print` and `debugPrint`
are intentionally excluded. Detailed error incidents share the stream and are
distinguished by `record_type` (`log`, `incident`, or `device_heartbeat`).

After machine information is available, an enabled monitoring build sends one
`device_heartbeat` immediately and then every 60 seconds. The record includes
`merchant_id`, `machine_id`, `shop_name`, `logo_image_url`, `machine_type`, App
version, and platform. Treat a machine as offline when its latest heartbeat is
older than 150 seconds; the App cannot send an explicit offline event after a
power loss, process kill, or network outage.

## Run the Flutter app against the local stack

From the repository root, run:

```bash
./run_android_dev.sh
```

The script selects the first online ADB device, chooses the Android 7 or
Android 11 dependency variant, and loads the agreed client URL and ingestion
key from `.openobserve-client.json`. Set `ANDROID_DEVICE_ID` only when the
automatic device selection needs to be overridden. Android and Windows use
the same client configuration and never need to inspect the Nginx container
when launching the App.

For development on a Windows computer, Docker can remain on this Mac or on a
separate server. Copy `.openobserve-client.example.json` to
`.openobserve-client.json` in the Windows checkout, replace the URL with the
Docker host's LAN address and set the same Nginx ingestion key. After this
one-time setup, `run_windows_dev.ps1` loads it automatically.

Platform-specific host URL:

- Windows/macOS/Linux desktop: `http://127.0.0.1:5080/app-events`
- Android emulator: `http://10.0.2.2:5080/app-events`
- Physical Android/iOS device: use the Docker host LAN IP and set `OPENOBSERVE_BIND_ADDRESS=0.0.0.0` in `.env`

Plain HTTP is only for local development. Use HTTPS before exposing the endpoint to a real point-of-sale machine or the internet.

## Stop and inspect

```bash
docker compose logs -f --tail=200
docker compose stop
docker compose start
```

To stop containers without deleting data:

```bash
docker compose down
```

Do not run `docker compose down -v` unless the OpenObserve data volume should be permanently deleted.

## Update credentials

The root password and its Basic value must stay in sync. After changing `OPENOBSERVE_ROOT_EMAIL` or `OPENOBSERVE_ROOT_PASSWORD`, regenerate the Basic value:

```bash
printf '%s' 'EMAIL:PASSWORD' | base64 | tr -d '\r\n'
```

Update `OPENOBSERVE_BASIC_AUTH`, then recreate Nginx:

```bash
docker compose up -d --force-recreate nginx
```

The App contains only `OPENOBSERVE_INGEST_KEY`, never the OpenObserve root credentials. Treat the key as replaceable rather than secret: keep rate limits enabled and rotate it when necessary.

## Backup

The named volume contains OpenObserve metadata, WAL, and stream data. Before a filesystem-level backup, stop OpenObserve so SQLite and WAL are consistent:

```bash
docker compose stop openobserve
docker run --rm \
  -v foodorder-openobserve-data:/source:ro \
  -v "$PWD/backups:/backup" \
  alpine:3.21 \
  tar -czf /backup/openobserve-data.tar.gz -C /source .
docker compose start openobserve
```

Keep backup archives outside the repository and test restoration periodically.
