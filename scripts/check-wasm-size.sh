#!/usr/bin/env bash
# Enforce a maximum size for each compiled Soroban contract (.wasm).
#
# Budgets should leave headroom below the Soroban deployment limit
# (~64 KB mainnet / ~128 KB testnet) to catch regressions early,
# instead of failing at deploy time.
#
# To add a new contract, extend the BUDGETS map below.
set -euo pipefail

# Directory where `cargo build --release --target wasm32v1-none` puts artifacts.
WASM_DIR="${WASM_DIR:-target/wasm32v1-none/release}"

# Per-contract size budgets in bytes.
# NOTE: these are conservative starting values and may be tightened once
# the real artifact sizes are known.
declare -A BUDGETS=(
  ["prediction_market"]=80000
)

fail=0

for contract in "${!BUDGETS[@]}"; do
  budget="${BUDGETS[$contract]}"
  wasm="${WASM_DIR}/${contract}.wasm"

  if [[ ! -f "$wasm" ]]; then
    echo "::error::WASM file not found: $wasm"
    fail=1
    continue
  fi

  # `wc -c` is POSIX and works on Linux, macOS and Termux alike.
  actual=$(wc -c < "$wasm")
  echo "[$contract] size=${actual}B budget=${budget}B"

  if (( actual > budget )); then
    echo "::error::${contract}.wasm exceeds budget: ${actual}B > ${budget}B"
    fail=1
  fi
done

exit "$fail"
