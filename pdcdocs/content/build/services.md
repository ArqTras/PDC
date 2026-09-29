---
title: Escrow, swaps, and offers
---

Besides ordinary transfers, the chain carries three service attachments: escrow, ionic swaps, and marketplace offers. Each one is optional. A normal PDC payment does not use them.

## Escrow

`src/currency_core/bc_escrow_service.h` defines service id `E`. The instructions a transaction can carry are:

| Instruction | Code | Role |
| --- | --- | --- |
| Proposal | `PROP` | Open an escrow |
| Release templates | `REL_TEMPL` | Templates for a later release |
| Cancel proposal | `CAN_PROP` | Withdraw the proposal |
| Release | `REL_N` | Release along the normal path |
| Cancel release | `REL_C` | Release along the cancel path |
| Burn release | `REL_B` | Release by burning |
| Change | `CHANGE` | Change the escrow |
| Private details | `DETAILS` | Details kept in the transaction extra |
| Public details | `PUB` | Public details in the extra |

The header describes the flow as a multisig-style escrow: a proposal, then a release or a cancel, with a burn path when the parties do not complete a normal release. Build these transactions in a wallet that understands the attachment. The daemon validates the attachment. It does not provide a separate "create escrow" RPC.

## Ionic swaps

`simplewallet` can exchange value with another party without handing the whole swap to a custodian:

| Command | Role |
| --- | --- |
| `generate_ionic_swap_proposal <proposal_config.json> <destination_addr>` | Build a proposal |
| `get_ionic_swap_proposal_info <hex_file>` | Show what a proposal contains before you accept it |
| `accept_ionic_swap_proposal <hex_file>` | Accept and produce the exchange transaction |

Read the proposal with `get_ionic_swap_proposal_info` before `accept_ionic_swap_proposal`. The hex file is the contract. Accepting it spends what the proposal says it spends.

## Marketplace offers

Offers are stored by `bc_offers_service`. An offer lives at most 30 days (`OFFER_MAXIMUM_LIFE_TIME`). The on-disk market file is `market.bin`.

The JSON-RPC method `marketplace_global_get_offers_ex` returns offers that match a filter. Small cancel-offer transactions can fall under the soft size limit `CURRENCY_FREE_TX_MAX_BLOB_SIZE` (1,024 bytes) that the pool uses for specific free-of-charge service instructions. Do not assume every offer update is free. A normal transfer still pays at least 0.01 PDC.
