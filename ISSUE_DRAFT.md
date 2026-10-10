# Historical note: retired systemic-invariants report

> **Status: RETIRED.** This file previously carried a living triage report
> titled *"Systemic accounting & state-invariant violation across
> prediction_market ↔ referral_registry ↔ leaderboard"*. That report asserted
> a family of defects at specific source line ranges and included inline code
> snippets. Every one of those defects has since been fixed, and the cited
> line numbers no longer resolve to the code they described. The report is
> kept here only as a short record of what was reported and how it was closed;
> the stale line-number citations and code snippets have been removed on
> purpose.

## Reported defects and their disposition

All defects below are **fixed**. No defect remains open, and none was retired
as invalid — each was a real issue that was resolved by an explicit repair.

| # | Reported defect | Disposition | Fix reference |
|---|-----------------|-------------|---------------|
| 1 | `cancel_market` reclaimed the full `TOTAL_FEE_BPS` fee from the global `AccumulatedFees` accumulator, over-reclaiming fees the platform never held and zeroing unrelated markets' fees. | **Fixed** | Per-market fee ledger (`DataKey::MarketAccumulatedFees` / `MarketFees`); cancel now reclaims the exact per-market balance. See issue #178 and the `market_fee_balance` reclaim in `prediction_market/src/lib.rs` (`cancel_market`). Related: #163, #87, #57. |
| 2 | `upsert_top` cached `MinPoints`/`MinSlot` and failed to recompute it on the partial-list path, letting a low-points player displace a high-points one. | **Fixed** | `upsert_top` now calls `recompute_min` on every mutation path, and the min is recomputed from live decayed points before any eviction (`leaderboard/src/lib.rs`). Related: #61. |
| 3 | A `HasReferrer` cache was never invalidated, so a user registering a referrer after their first bet never paid that referrer. | **Fixed** | The cache was deleted; `referral_registry::credit` performs a live referrer lookup (double-`Option` read + `flatten`) at bet time, so late registration is honored. See issue #99. |
| 4 | `place_bet` performed external calls before writing `BetEntry`/market totals, allowing a reentrant referrer contract to observe partially-updated state. | **Fixed** | `place_bet` now takes a per-bet reentrancy lock and writes all state (fees, `BetEntry`, bettor index, market totals) *before* any external call, restoring check-effects-interaction ordering (`prediction_market/src/lib.rs`). See issue #89. |
| 5 | `presago_token::mint` had no supply ceiling, so `claim`/`reward` could inflate PULSE without bound. | **Fixed** | The token exposes an admin `set_supply_cap` / `get_supply_cap`, and `mint` enforces the cap before any state change (`pulse_token/src/lib.rs`, `TokenError::SupplyCapExceeded`). See issue #79. |

## Notes

- The original report's summary said "four" defects while its body enumerated
  five sections; the discrepancy is preserved here as part of the historical
  record. All five enumerated sections were real and are now fixed.
- The report also cited an unbounded `LOSE_TOKENS` mint. That constant has been
  removed entirely (issue #24): a loss now costs points via
  `leaderboard::penalize` and mints no tokens, so there is nothing left to
  capitalize. This reference is retired, not outstanding.
- Do not reintroduce line-number citations here. If future work needs a
  triage report, open a fresh issue and cite symbols/commits rather than
  ephemeral line ranges.
