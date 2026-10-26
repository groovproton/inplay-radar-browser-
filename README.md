# InPlay Radar — Binance Action Indicator

Browser-only scanner of **real-time activity in Binance Spot USDT markets**. It identifies changes in trading intensity; it is **not a directional trading signal**.

## Architecture

```text
Binance !ticker_1d@arr
        |
   USDT discovery
   (24h liquidity + 10s price movement)
        |
 Candidate ranking: enter Top 50 / exit below Top 70
        |
 Binance combined @aggTrade subscriptions
        |
 Quote turnover + aggregated-trade event intensity
 10s current window / up to 50s preceding baseline
        |
 Price change 10s / 30s / 60s + acceleration
        |
 Action Score -> smoothed state machine
        |
 Browser dashboard (active coins + candidate list)
```

Runs entirely in a browser in one `index.html`; no Node.js, npm, package.json, framework, API keys, backend or bundler.

## Quick start

```sh
make serve
# visit http://127.0.0.1:8000/
```

Or: `python3 -m http.server 8000 --bind 127.0.0.1`. Stop foreground serving with Ctrl+C. `make start`, `make stop`, `make status`, and `make restart` manage a background server; `PORT=8080 make serve` changes the port.

## Data and calculation

- **Discovery:** `wss://stream.binance.com:9443/ws/!ticker_1d@arr` provides 24-hour rolling ticker information, not a 1-minute trade feed.
- **Activity:** `wss://stream.binance.com:9443/stream` with dynamic `<symbol>@aggTrade` subscriptions provides aggregated executions for selected candidates.
- **Price movement:** differences from ticker snapshots nearest 10, 30 and 60 seconds ago (within 2.5 seconds tolerance).
- **Quote Vol Ratio:** quote turnover in the most recent 10 seconds divided by average 10-second quote turnover in the preceding available baseline (up to 50 seconds). The preceding baseline excludes the most recent 10 seconds.
- **AggTrade Ratio:** same comparison using **aggregated trade events**, not the total number of individual executions.
- **Acceleration:** absolute percentage change per second in the recent 10 seconds minus that over 30 seconds, using only the positive component in the score.
- **Action Score:** weighted magnitude of price movement, positive acceleration and excess volume/event-rate ratios, each with a capped ratio contribution.
- **Confidence:** WARMUP/LOW/MED/FULL based on elapsed observation and usable price snapshots. A symbol without a confirmed subscription or with stale discovery data is held in WARMUP.

## Market states

`QUIET → WAKING → ACTIVE → EXPANDING` (or back down). States use an exponentially smoothed score, distinct enter/exit thresholds, confirmation time, confidence caps and minimum hold time. Active coins remain visible for up to 5 minutes after last being active. Recently active candidates are retained for an additional 2 minutes so brief pauses do not immediately terminate detailed monitoring.

## WebSocket reliability

- Discovery and activity sockets reconnect with exponential backoff plus jitter.
- Subscription state is updated **after Binance acknowledges** SUBSCRIBE/UNSUBSCRIBE, not merely on send. Errors are logged and retried; unanswered commands trigger reconnect after 10 seconds.
- Activity history is reset on a new subscription, avoiding reuse of samples across gaps; reconnect resets activity readiness.
- Discovery has a 15-second stale timeout, surfaced in the status line. A missing `aggTrade` on a single quiet symbol is **not** by itself proof of a broken connection.
- The browser's displayed confirmation status and score quality do not guarantee that every upstream market event was delivered. There is no historical backfill or complete trade-sequence audit.

## Limitations

Candidate discovery uses rolling 24-hour turnover and ticker changes. A very quiet/low-liquidity symbol may not be shortlisted even if it begins an interesting move. `@aggTrade` combines eligible individual trades into aggregate events. Neither AggTrade Ratio nor the score equals true trade count, order-flow delta, CVD, or probability of profitable movement.

## Project files

```text
index.html   Browser-only scanner (HTML + CSS + JavaScript)
README.md    Project explanation
Makefile     Local static HTTP server
```
