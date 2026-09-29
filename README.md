# PDC documentation

English manual for Privacy Data Coin. The section order follows a full-chain manual: learn the protocol, use a wallet, build and integrate, mine, stake, and read the source. The colors, the logo, and the facts are PDC.

Numbers come from [ArqTras/pdc](https://github.com/ArqTras/pdc) branch `pdc`, especially `src/currency_core/currency_config.h`, and from [release v2.0.0](https://github.com/ArqTras/pdc/releases/tag/v2.0.0) (17 September 2026). That release resets the network and does not speak to v1.0.0.7.

## Read it

The markdown sources are in `content/`. The pages you open in a browser are the HTML files next to this README. Regenerate them after an edit:

```text
python3 -m pip install markdown
python3 tools/build.py
```

Public references used in the manual:

- Site: https://privacydatacoin.com/
- Explorer: https://explorer.privacydatacoin.com/
- Asset whitelist: https://api.privacydatacoin.com/assets_whitelist.json

## Sections

- Learn: what PDC is, how a transfer works, FAQ
- Use: install v2.0.0, wallets, security, troubleshooting
- Build: compile the tree, node RPC, assets, aliases, escrow and swaps
- Mine: RandomARQ and stratum port 19777
- Stake: online staking and the Zarcanum rules
- Code: the parameter table and a map of the source tree
