# BWS — Binance Action Indicator

Browser-only, real-time scanner for **active Binance Spot USDT pairs**. BWS ranks symbols by changes in market activity so that coins waking up *now* stand out from coins that merely have a large 24-hour price change.

## Features (V1)

- Live Binance market feed over WebSocket (`!ticker@arr`).
- Filters for USDT trading pairs.
- Maintains approximately 120 seconds of recent ticker snapshots.
- Compares changes across 10-, 30-, and 60-second windows.
- Computes an **Action Score** to rank symbols by activity.
- Classifies market activity as `QUIET`, `WAKING`, `ACTIVE`, or `EXPANDING`.
- Displays up to 50 candidates, refreshing the table approximately every 500 ms.
- Uses a minimum 24-hour quote-volume filter (initial V1 default: 500,000 USDT).
- Reconnects if the WebSocket connection drops (initial V1 delay: 2 seconds).

> This is an **activity detector**, not a buy/sell signal. High activity does not necessarily imply sustained directional movement.

## Requirements

- A modern browser with WebSocket support.
- Python 3 (only to serve static files locally).
- `make` (optional convenience wrapper).
- Internet connectivity to Binance's public market-data endpoint.

No Node.js, `npm`, `package.json`, frontend framework, build step, API keys, or application backend is required.

## Quick start

From the project directory:

```sh
make serve
```

Open <http://localhost:8000/>.

The command runs in the foreground; press **Ctrl+C** to stop it.

Alternatively, run without Make:

```sh
python3 -m http.server 8000 --bind 127.0.0.1
```

Alternatively, stop without Make:

```sh
kill $(lsof -tiTCP:8000 -sTCP:LISTEN)
```



If you previously configured the local hostname `bws.local` to resolve to `127.0.0.1`, you can also open <http://bws.local:8000/>.

## Makefile commands

| Command | Action |
| --- | --- |
| `make help` | Display available commands. |
| `make serve` | Run the development HTTP server in the foreground. |
| `make start` | Start the server in the background. |
| `make status` | Show whether the managed background server is running. |
| `make stop` | Stop the server started with `make start`. |
| `make restart` | Stop and restart the managed background server. |

Override the port if necessary:

```sh
make serve PORT=8080
```

For background operation, use the same `PORT` value for `start`, `status`, and `stop`.

## How it works

```text
Binance Spot WebSocket (!ticker@arr)
               |
          USDT filter
               |
     Recent ticker history
               |
   10s / 30s / 60s changes
               |
   Action Score + state
               |
     Ranked live dashboard
```

The V1 market stream provides **24-hour rolling ticker statistics**. BWS measures *changes in those statistics over short intervals* to estimate recent activity; it is not directly consuming individual trades. As a result, these estimates are not identical to exact trade counts, exact 1-minute quote volume, order-flow delta, or CVD derived from `trade`/`aggTrade` events.

## Project structure

```text
bws/
├── index.html      # Browser application (V1)
├── README.md       # Project documentation
└── Makefile        # Local development commands
```

## Notes

- Data is public; no trading or order execution takes place.
- The browser connects directly to Binance. Availability depends on network access and the Binance stream service.
- V1 prioritizes finding sudden activity; whether an active coin is suitable for trading requires separate price/structure analysis.
