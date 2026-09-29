---
title: Build from source
---

The repository is [github.com/ArqTras/pdc](https://github.com/ArqTras/pdc), branch `pdc`. Clone it with submodules. A clone without `--recursive` misses the bundled libraries and will not configure.

```text
git clone --recursive https://github.com/ArqTras/pdc.git -b pdc
```

The README in that repository is the long-form build guide. This page is the map. If a checksum or an installer URL in the README and a newer release note disagree, follow the file you are actually building.

## What the build produces

| Target | Binary | You need it for |
| --- | --- | --- |
| `daemon` | `daemon` | A full node |
| `simplewallet` | `simplewallet` | Command-line wallet |
| `Pdc` | desktop wallet | Everyday use and staking with a GUI |
| `connectivity_tool` | connectivity tool | Peer and network checks |

CMake also builds test targets (`coretests`, `crypto-tests`, and others) under `tests/`. They are for contributors, not for mainnet.

## Dependencies the README lists

| Component | Recommended in the README |
| --- | --- |
| GCC | 9.4.0 |
| CMake | 3.26.3 |
| Boost | 1.84 |
| OpenSSL | 1.1.1w |
| Qt, GUI only | 5.11.2 in the README. The CMake file uses Qt 6 when Qt 5 WebEngine is absent |

Recommended Linux in the README is Ubuntu 20.04 or 22.04 LTS. The GUI AppImage in release <a data-doc-release href="https://github.com/PrivacyDataCoin-Project/pdc/releases/latest"><span data-doc-version>v2.1.0</span></a> is built for Ubuntu 22.04.

Server packages from the README:

```text
sudo apt-get install -y build-essential g++ curl autotools-dev libicu-dev libbz2-dev cmake git screen checkinstall zlib1g-dev
```

The GUI package list adds `mesa-common-dev` and `libglu1-mesa-dev`.

## A node-only build

After Boost and OpenSSL are installed and `BOOST_ROOT` and `OPENSSL_ROOT_DIR` point at them:

```text
cd pdc
mkdir build && cd build
cmake ..
make -j1 daemon simplewallet
```

`-j1` is the README's safe default. Raise it only when the machine has enough RAM. A testnet binary is `cmake -D TESTNET=TRUE ..`. Testnet uses different ports and different hard-fork heights. Do not point a testnet binary at mainnet peers and expect them to sync.

The Linux GUI script in the repository is `utils/build_script_linux.sh`. Windows builds start from `utils/configure_local_paths.cmd` and a Visual Studio generator script. macOS builds start from `utils/macosx_build_config.command` and `utils/build_script_mac_osx.sh`. Those scripts are the platform-specific steps. Read them before you run them, and edit the paths so they match the machine.

## Where the node writes data

The default data directory is `~/.PDC` on Linux, `~/Library/Application Support/PDC` on macOS, and the roaming `PDC` folder on 64-bit Windows. `--data-dir` overrides it.

Inside that folder the chain uses a directory whose name starts with `blockchain_` and ends with `_v2`. The peer cache is `p2pstate.bin`. The GUI keeps `gui_settings.json` and `gui_secure_conf.bin`. The miner config file name is `miner_conf.json`.
