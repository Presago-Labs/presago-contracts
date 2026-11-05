#!/usr/bin/env bash
set -euo pipefail

# Soroban mainnet/testnet protocol max contract WASM size is 128 KiB (131,072 bytes).
# With [profile.release] opt-level = "z", strip = "symbols", codegen-units = 1, and lto = true,
# prediction_market.wasm compiles to ~89.5 KiB (~91,600 bytes), while pulse_token, leaderboard,
# and referral_registry compile to 10-35 KiB each.
# We enforce a committed 96 KiB (98,304 bytes) per-contract budget (~10% headroom above
# prediction_market.wasm and 25% below the 128 KiB Soroban ledger ceiling) so any accidental
# size regression or removal of release LTO/strip flags fails CI immediately.
WASM_BUDGET_BYTES="${WASM_BUDGET_BYTES:-98304}"
RELEASE_DIR="${1:-target/wasm32v1-none/release}"

CONTRACTS=(
  "prediction_market"
  "pulse_token"
  "leaderboard"
  "referral_registry"
)

failed=0
echo "=== Soroban WASM Size Budget Check (Budget: ${WASM_BUDGET_BYTES} bytes / 96 KiB) ==="
for contract in "${CONTRACTS[@]}"; do
  wasm_file="${RELEASE_DIR}/${contract}.wasm"
  if [ ! -f "${wasm_file}" ]; then
    echo "::error file=${wasm_file}::Missing compiled WASM artifact: ${wasm_file}"
    failed=1
    continue
  fi
  actual_bytes=$(wc -c < "${wasm_file}" | tr -d '[:space:]')
  pct=$(( actual_bytes * 100 / WASM_BUDGET_BYTES ))
  echo "  - ${contract}.wasm: ${actual_bytes} / ${WASM_BUDGET_BYTES} bytes (${pct}%)"
  if [ "${actual_bytes}" -gt "${WASM_BUDGET_BYTES}" ]; then
    echo "::error file=${wasm_file}::${contract}.wasm (${actual_bytes} bytes) exceeds WASM size budget (${WASM_BUDGET_BYTES} bytes)"
    failed=1
  fi
done

if [ "${failed}" -ne 0 ]; then
  echo "WASM size budget check FAILED."
  exit 1
fi
echo "All Soroban contract WASM binaries are within the ${WASM_BUDGET_BYTES}-byte budget."
