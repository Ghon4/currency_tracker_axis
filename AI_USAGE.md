# AI Usage Log

This document tracks how I used AI (Cursor) to build the Currency Tracker Axis app, along with the decisions I made along the way.

## Overview

I used AI to help with the boring stuff - scaffolding the clean architecture layers, setting up BLoC state management, wiring up Hive cache, building the chart UI, writing tests, and documentation. It saved me a ton of time, but I still had to make judgment calls on the tricky parts.

Some things I changed: the TTL policy (went with 24 hours), how soft-fail snackbars work, and ended up hand-writing Hive adapters instead of dealing with Freezed conflicts. I also said no to some over-engineered ideas like clearing cache on app termination - that would've defeated the whole offline requirement.

## Phase by Phase

### Phase 1 — Foundation (2026-09-08 23:52)

**What I asked for:** Set up the project foundation - folders, DI, Dio, connectivity, Hive stubs, theme, router, and Freezed failures.

**What AI gave me:** All the core packages, AppConstants, HiveService with schema migration, DioClient with interceptors, GetIt registration, main.dart and app shell.

**My call:** Accepted, but with some changes

**Why:** The architecture matched my plan. But I ran into a problem with hive_generator conflicting with Freezed 3, so I ditched the codegen and wrote the Hive adapters manually. Annoying but it worked.

**Commit:** `25c4c1d` — feat: setup project foundation and core infrastructure

### Phase 2 — Domain & Data (2026-09-09 00:24)

**What I asked for:** Domain entities, repositories, mappers with rate inversion logic, remote/local datasources, use cases.

**What AI gave me:** CurrencyRate, CachedRates, HistoricalPoint entities, RateMapper with inversion, repository with cache fallback, and historical data handling with partial success.

**My call:** Accepted, with a couple tweaks

**Why:** The inversion logic and null-change handling for missing yesterday data was spot-on. I had to adjust the cache validity later in Phase 5 when I settled on a 24-hour TTL instead of same-day freshness.

**Commit:** `3201769` — feat: implement domain and data layer

### Phase 3 — Module 1 List (2026-09-09 00:48)

**What I asked for:** Exchange rates list UI with BLoC, shimmer loading, offline banner, pull-to-refresh, and connectivity refresh.

**What AI gave me:** ExchangeRatesBloc, page, list tiles, RateChangeIndicator with proper color logic, and shared error/empty widgets.

**My call:** Accepted as-is

**Why:** The event set was exactly what I wanted - LoadRates, RefreshRates, ConnectivityRestored - and the cache-first UX matched my plan perfectly. Pull-to-refresh kept the previous list visible while loading, which feels much better than a blank screen.

**Commit:** `2443506` — feat: implement exchange rates list module

### Phase 4 — Module 2 Detail / Chart (2026-09-09 01:28)

**What I asked for:** Currency detail page with header and 7-day fl_chart, with independent header and chart loading states.

**What AI gave me:** CurrencyDetailBloc, chart shimmer and error states, historical remote fan-out, detail route with go_router.

**My call:** Accepted with some polish later

**Why:** The architecture was solid. I deferred some chart polish (RepaintBoundary, AnimatedSwitcher) to Phase 5 because I wanted to focus on getting the core working first. The partial history handling without a "partial" flag was a good call - just show what you have.

**Commit:** `5a86b18` — feat: implement currency detail with chart

### Phase 5 — Cache, Errors, Tests (2026-09-09 ~01:31+)

**What I asked for:** 24-hour TTL with two-tier cache, 2-second reconnect debounce for auto-refresh, error messages with RetryPolicy, GlobalErrorHandler, tests, AI_USAGE + README, and performance hygiene.

**What AI gave me:**
- MemoryRatesCache + CacheOperations with 24h TTL
- Local DS delegating to CacheOperations
- ErrorMessages, expanded Failure types, RetryPolicy categories
- BLoC with 2s reconnect debounce and TTL-aware refresh
- OfflineBanner with timestamp + stale warning
- Detail: cache-first chart then network refresh
- Tests and docs

**My call:** Accepted with some changes

**Why:**
- **Kept:** 24h TTL, two-tier cache, 2s debounce, user-facing error messages, RetryPolicy categories.
- **Changed:** The soft-fail behavior was tricky - when refreshing, I keep the previous Success state instead of showing an error. Also, I made sure NOT to clear Hive on app termination, since offline access is a core requirement.
- **Rejected:** Some technical exception strings made their way into the UI - I rewrote those to be user-friendly. Also, I went with 24-hour TTL instead of same-day UTC freshness because it's simpler and more predictable.

**Commit:** (Phase 5 commit - pending)

## What I Learned

- Lock in your TTL and reconnect rules early. Changing from "same calendar day" to "24-hour window" late in the game affects everything.
- Soft-fail UX is harder than it looks - you need to handle the case where you're showing cached data while a refresh fails.
- Freezed + hive_generator don't play nice together. Save yourself the headache and just write adapters manually.
- Use fake_async for tests involving retry backoff and debouncing. Makes the tests fast and deterministic.
- Keep AI_USAGE.md in the same commit history as the work it describes - easier to track changes.

## Commit History

```bash
git log --oneline
```

Expected commits:

1. `25c4c1d` (2026-09-08 23:52) — Foundation
2. `3201769` (2026-09-09 00:24) — Domain & Data
3. `2443506` (2026-09-09 00:48) — Module 1 List
4. `5a86b18` (2026-09-09 01:28) — Module 2 Detail
5. Phase 5 — Cache / Errors / Testing (coming soon)
