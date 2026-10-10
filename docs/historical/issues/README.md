# Historical security audit (archived)

This directory is a **historical record, not a bug tracker.** It holds the 40
reports (`issue-02.md` … `issue-41.md`) from the security audit committed on
2026-08-16 in `f7978da`. They were written against an older revision of the
contracts, so the line numbers and code fragments they quote no longer match
`main`.

Every file in this directory carries a banner marking it historical. No report
here should be treated as open work: the current source and test suite are the
source of truth. If a still-relevant item below matters, please open a fresh
issue against the current tree instead of reviving these files.

## Resolution summary

The hardening work merged after this snapshot addressed most of the reported
defects. Representative fixes now in the tree:

- **prediction_market** — event emission, per-market fee ledger (`MarketFees`),
  payout-dust settlement, empty-side challenge window, capped/timelocked
  withdrawals, staged multi-governor config changes, ABI-version pinning,
  minimum market duration, bounded bettor pagination, saturating rate checks,
  TTL bumps on read paths, and an emergency pause.
- **leaderboard** — write-time ordered top list (bounded reads), player
  ban/remove, points decay/penalty, TTL bumps, and legacy-slot migration.
- **referral_registry** — registered-referrer validation, referral depth cap,
  TTL extension for referral history, refunds to the bettor rather than the
  caller, and an emergency pause.
- **pulse_token** — supply cap, approve/allowance, TTL bumps on balance keys,
  and idempotent minter add/remove.

## Per-report status

| Report | Severity | Topic | Status |
| --- | --- | --- | --- |
| issue-02 | CRITICAL | Payout rounding traps dust | Resolved — dust settled; sum of payouts reconciles |
| issue-03 | CRITICAL | Empty-side resolution sweeps pool to fees | Resolved — empty-side vault + challenge window |
| issue-04 | CRITICAL | Global fee pool lacks provenance | Resolved — per-market `MarketFees` ledger |
| issue-05 | CRITICAL | Untimelocked `upgrade()` | Resolved — staged 7-day delay (`CONFIG_DELAY_SECS`) |
| issue-06 | CRITICAL | Unvalidated `set_config` re-pointing | Resolved — staged, fingerprinted, multi-governor approval |
| issue-07 | HIGH | No event emission | Resolved — events published in all contracts |
| issue-08 | HIGH | Unbounded bettor iteration | Resolved — bounded `get_market_bettors_page` |
| issue-09 | CRITICAL | TTL expiry before claims/refunds | Resolved — TTL bumps on read paths |
| issue-10 | MEDIUM | `duration_secs = 0` allowed | Resolved — minimum market duration + open-market cap |
| issue-11 | MEDIUM | `check_rate` underflow on regression | Resolved — saturating ledger-sequence window |
| issue-12 | HIGH | Uncapped `withdraw_fees` | Resolved — cap, timelock, recipient validation |
| issue-13 | MEDIUM | `cancel_refund` leaves `net` intact | Resolved — zeroes `gross` and both nets |
| issue-14 | MEDIUM | `OppositeSideBet` locks a user to one side | Resolved — single-entry invariant kept by design, documented |
| issue-15 | LOW | `MIN_BET` checked on gross | Resolved — checked on net stake |
| issue-16 | HIGH | O(n²) `get_top_players` | Resolved — ordered index, O(page) reads |
| issue-17 | MEDIUM | `get_rank` returns 0 off-list | Resolved — returns real rank or `UNRANKED_RANK` |
| issue-18 | HIGH | Divergent `reward`/`add_pts` paths | Resolved — single canonical reward path |
| issue-19 | MEDIUM | `reward_bonus` undercounts bets | Resolved — `bonus_bets` tracked; `total_bets` derived |
| issue-20 | MEDIUM | No leaderboard ban/remove | Resolved — ban + remove |
| issue-21 | MEDIUM | `MinPoints`/`MinSlot` TTL | Resolved — instance TTL bumped |
| issue-22 | MEDIUM | Orphaned `TopPlayerSlot` entries | Resolved — slot/index written together; rebuild/compact |
| issue-23 | MEDIUM | Pagination re-scans list | Resolved — O(page_size) ordered read |
| issue-24 | LOW | Points never decay | Resolved — periodic decay + loss penalty |
| issue-25 | MEDIUM | `upsert_top` min tracking | Resolved — write-time ordered index, fixed comparisons |
| issue-26 | MEDIUM | Unregistered referrer paid | Resolved — `InvalidReferrer` check |
| issue-27 | CRITICAL | `credit` fund-drain / arbitrary address | Resolved — market-caller auth + registered referrer |
| issue-28 | MEDIUM | Referral history TTL | Resolved — TTL extended on write/read |
| issue-29 | HIGH | No referral depth limit | Resolved — `MAX_REFERRAL_DEPTH` |
| issue-30 | MEDIUM | No `display_name` length limit | No remediation found in current tree — re-file if still relevant |
| issue-31 | MEDIUM | `credit` refunds the caller | Resolved — refunds the bettor directly |
| issue-32 | MEDIUM | No referral earnings cap | No remediation found in current tree — re-file if still relevant |
| issue-33 | MEDIUM | Legacy key migration inconsistency | Resolved — one-shot `migrate_top_players` |
| issue-34 | CRITICAL | No PULSE supply cap | Resolved — `set_supply_cap` enforced before mint |
| issue-35 | LOW | `set_minter` idempotency | Resolved — `AlreadyMinter`/`NotMinter` guards |
| issue-36 | MEDIUM | `transfer`/`burn` TTL | Resolved — balance TTL extended |
| issue-37 | MEDIUM | No approve/allowance | Resolved — `approve`/`allowance` added |
| issue-38 | HIGH | No pause/circuit breaker | Resolved — emergency pause across contracts |
| issue-39 | HIGH | Uncoordinated upgrades break ABI | Resolved — expected interface versions + migration entries |
| issue-40 | HIGH | No trust revocation | Resolved — staged multi-governor config re-pointing |
| issue-41 | MEDIUM | No cross-contract gas management | Partially addressed — unbounded iterations removed; no explicit runtime budget API |

Statuses above reflect a review of the tree at the time of archiving. They are
provided for provenance only and are not a substitute for the current test
suite.
