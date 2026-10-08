# Presago Contracts

![CI](https://github.com/Presago-Labs/presago-contracts/actions/workflows/ci.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![Stellar](https://img.shields.io/badge/Stellar-Soroban-7D00FF?logo=stellar&logoColor=white)

This repository contains the Soroban smart contract workspace for Presago.

## Table of Contents

- [How it uses Stellar](#how-it-uses-stellar)
- [Included contracts](#included-contracts)
- [Workspace](#workspace)
- [Prerequisites](#prerequisites)
- [Development](#development)
- [Security](#security)

## How it uses Stellar

The **Soroban** smart-contract workspace behind [Presago](https://github.com/Presago-Labs/presago), deploying to the **Stellar** network. It defines how XLM enters a market pool, how positions are reduced, and how resolved or cancelled markets account for payouts and refunds, emitting Stellar events for indexers.

## Included contracts

- prediction_market
- presago_token
- referral_registry
- leaderboard
- ipredict_token

## Workspace

The workspace is managed by the root Cargo.toml file.

## Prerequisites

| Tool | Notes |
| --- | --- |
| **Rust 1.91.0** | pinned in `rust-toolchain.toml` |
| **`wasm32v1-none` target** | `rustup target add wasm32v1-none` |
| **Stellar CLI** | only for deployment |

## Development

```bash
cargo test --workspace
```

## Security

- **Never commit secrets** — keep keys, seed phrases, and `.env` files out of source control.
- **Testnet values have no real-world value**; treat testnet deployments as experimental.
- **Keys never leave the wallet** — signing is delegated to the user's Stellar wallet; the app does not store secret keys.
- Report vulnerabilities per `SECURITY.md` where present rather than opening a public issue.

## License

MIT — see [`LICENSE`](LICENSE).
