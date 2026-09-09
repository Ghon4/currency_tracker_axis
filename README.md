# Currency Tracker Axis

Flutter app that tracks **Egyptian Pound (EGP)** exchange rates against USD, EUR, GBP, SAR, and JPY — with daily change, a 7-day chart, offline Hive cache, and connectivity-aware auto-refresh.

## Features

- Live inverted rates (EGP per 1 foreign unit)
- Daily absolute + percentage change vs yesterday
- Currency detail screen with 7-day historical line chart
- Offline cache (memory + Hive) with **24-hour TTL**
- Pull-to-refresh and auto-refresh ~2s after reconnect when cache is stale/cached
- Offline banner with last-updated timestamp (and stale warning after 24h)
- User-friendly error messages + retry

## Architecture

Clean architecture + BLoC:

```text
┌─────────────────────────────────────────────┐
│                 Presentation                │
│   Pages / Widgets / BLoCs (flutter_bloc)    │
└─────────────────────┬───────────────────────┘
                      │ use cases
┌─────────────────────▼───────────────────────┐
│                   Domain                    │
│   Entities · Repository contracts · UCs     │
└─────────────────────┬───────────────────────┘
                      │
┌─────────────────────▼───────────────────────┐
│                    Data                     │
│  Remote (Dio + RetryPolicy)                 │
│  Local (MemoryRatesCache → Hive)            │
│  Mappers / Repository impls                 │
└─────────────────────────────────────────────┘
```

Core cross-cutting: connectivity, error mapping, cache TTL, DI (`get_it`), routing (`go_router`).

## Tech stack

| Area | Packages |
|------|----------|
| UI | Flutter, Material 3, `fl_chart`, `shimmer`, `intl` |
| State | `flutter_bloc`, `equatable`, `freezed` |
| Network | `dio`, `connectivity_plus` |
| Cache | `hive` / `hive_flutter` (+ in-memory tier) |
| DI / nav | `get_it`, `go_router` |
| FP | `dartz` (`Either`) |
| Tests | `flutter_test`, `bloc_test`, `mocktail`, `fake_async` |

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK compatible with `pubspec.yaml`).
2. From the project root:

```bash
flutter pub get
dart run build_runner build
flutter run
```

## API

Public currency CDN (no API key):

- Latest: `https://latest.currency-api.pages.dev/v1/currencies/egp.json`
- Historical: `https://{yyyy-MM-dd}.currency-api.pages.dev/v1/currencies/egp.json`

Rates are stored as **foreign units per 1 EGP**. The app **inverts** them to **EGP per 1 foreign unit** before display (e.g. `egp.usd = 0.019227` → ≈ `52.01`).

## Offline & cache

- Writes go to **memory** then **Hive**.
- Reads check memory first, then Hive (hydrating memory).
- Cache is **valid for 24 hours** from the stored timestamp.
- Schema version bumps clear persisted boxes automatically.
- Cache is **not** cleared on app terminate (required for offline).

## Testing

```bash
flutter analyze
flutter test
```

Coverage includes mappers, repository fallback, retry/TTL, both BLoCs, offline banner, pages, and flow-style widget tests under `test/integration/`.

*(Placeholders — capture after `flutter run`.)*

## AI assistance

See [AI_USAGE.md](AI_USAGE.md) for phase prompts, model outputs, and accept/edit/reject decisions.
