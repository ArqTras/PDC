---
title: Proof of stake
---

This page is the protocol view of staking. The operating view is [Staking](staking.md).

## Targets

`DIFFICULTY_POS_TARGET` is 120 seconds. `DIFFICULTY_POW_TARGET` is also 120 seconds. The chain's overall target is `(120 + 120) / 4 = 60` seconds. Difficulty for each side moves across `DIFFICULTY_WINDOW` (720) blocks, ignoring `DIFFICULTY_LAG` (15) recent blocks and cutting `DIFFICULTY_CUT` (60) extreme timestamps.

`POS_START_HEIGHT` is 0. The first blocks of mainnet are allowed to be proof of stake. `DIFFICULTY_POS_STARTER` is 1.

## Age and the kernel

A coinstake younger than 10 blocks cannot be used. After hard fork 4 the mandatory minimum coin age is also 10 (`CURRENCY_HF4_MANDATORY_MIN_COINAGE`). The wallet scans timestamps in steps of 15 seconds and will not mine a stake timestamp further ahead than `POS_MAX_ACTUAL_TIMESTAMP_TO_MINED`, which is the 10-minute scan window plus 100 seconds.

The modifier for the stake kernel changes every `POS_MODFIFIER_INTERVAL` (10) blocks. The starter kernel hash is the constant `POS_STARTER_KERNEL_HASH` in `currency_config.h`.

## Zarcanum

Hard fork 4 is `ZANO_HARDFORK_04_ZARCANUM` in the source, active after height 100 on mainnet. The timestamp constant next to it records a historical clock value. The height is the rule the node enforces.

Before that height, proof of stake exists without the Zarcanum amount proof. After it, the stake is a Zarcanum proof: the odds follow the coins you lock into the coinstake, and the amount stays inside the proof. Transaction version 2 is required in this zone. Decoy sets on ordinary transfers become 15 at the same fork. Those are different mechanisms that share a height.

## The sequence limit

A proof-of-stake block carries a sequence factor. The highest allowed factor is 20, so 21 stake blocks can follow each other. `getinfo` can report the current factors when you set `COMMAND_RPC_GET_INFO_FLAG_POS_SEQUENCE_FACTOR` and `COMMAND_RPC_GET_INFO_FLAG_POW_SEQUENCE_FACTOR`.

## Asking the node

`get_pos_details.bin` returns the proof-of-stake conditions the wallet uses to decide whether a kernel wins. It is a binary wallet call, not a convenience JSON method. `getblocktemplate` can also build a proof-of-stake template when the request asks for one. The struct comments in `core_rpc_server_commands_defs.h` describe both.

If you are checking that staking is alive, `getinfo` with the proof-of-stake difficulty bit (`0x1`) and the last proof-of-stake timestamp bit (`0x100`) is enough.
