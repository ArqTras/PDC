---
title: Getting started
---

Use release <a data-doc-release href="https://github.com/PrivacyDataCoin-Project/pdc/releases/latest"><span data-doc-version>v2.1.0</span></a>, published <span data-doc-date>28 September 2026</span>. That number is the latest release of [PrivacyDataCoin-Project/pdc](https://github.com/PrivacyDataCoin-Project/pdc). Release v2.0.0 reset the network and does not speak to v1.0.0.7. Stay on the current release for both the wallet and the node.

<div data-release-files>
<table>
<thead><tr><th>File</th><th>Role</th><th>Size</th></tr></thead>
<tbody>
<tr><td><a href="https://github.com/PrivacyDataCoin-Project/pdc/releases/download/v2.1.0/Pdc-GUI-v2.1.0-ubuntu-22.04.AppImage">Pdc-GUI-v2.1.0-ubuntu-22.04.AppImage</a></td><td>Linux desktop wallet</td><td>169 MB</td></tr>
<tr><td><a href="https://github.com/PrivacyDataCoin-Project/pdc/releases/download/v2.1.0/Pdc-Gui-v2.1.0-ubuntu-22.04.tar.gz">Pdc-Gui-v2.1.0-ubuntu-22.04.tar.gz</a></td><td>Linux desktop wallet archive</td><td>164 MB</td></tr>
<tr><td><a href="https://github.com/PrivacyDataCoin-Project/pdc/releases/download/v2.1.0/Pdc-Gui-v2.1.0-windows.exe">Pdc-Gui-v2.1.0-windows.exe</a></td><td>Windows installer</td><td>98 MB</td></tr>
<tr><td><a href="https://github.com/PrivacyDataCoin-Project/pdc/releases/download/v2.1.0/Pdc-Gui-v2.1.0-windows.zip">Pdc-Gui-v2.1.0-windows.zip</a></td><td>Windows desktop wallet archive</td><td>118 MB</td></tr>
<tr><td><a href="https://github.com/PrivacyDataCoin-Project/pdc/releases/download/v2.1.0/Pdc-Gui-v2.1.0-osx.tar.gz">Pdc-Gui-v2.1.0-osx.tar.gz</a></td><td>macOS desktop wallet</td><td>154 MB</td></tr>
<tr><td><a href="https://github.com/PrivacyDataCoin-Project/pdc/releases/download/v2.1.0/Pdc-v2.1.0-ubuntu-22.04.tar.gz">Pdc-v2.1.0-ubuntu-22.04.tar.gz</a></td><td>Linux daemon and simplewallet</td><td>50 MB</td></tr>
<tr><td><a href="https://github.com/PrivacyDataCoin-Project/pdc/releases/download/v2.1.0/Pdc-v2.1.0-windows.zip">Pdc-v2.1.0-windows.zip</a></td><td>Windows daemon and simplewallet</td><td>10 MB</td></tr>
<tr><td><a href="https://github.com/PrivacyDataCoin-Project/pdc/releases/download/v2.1.0/Pdc-v2.1.0-osx.tar.gz">Pdc-v2.1.0-osx.tar.gz</a></td><td>macOS daemon and simplewallet</td><td>12 MB</td></tr>
</tbody>
</table>
</div>

The GUI binaries in that release are a Qt 6 build. A source build uses Qt 5 WebEngine when it is installed, and Qt 6 otherwise.

## First launch

1. Install the desktop wallet, or unpack the command-line archive.
2. Let the node sync from the seed `169.58.142.131:19121`. A new node keeps that seed as a priority peer so it still has someone to stay connected to when the seed's peer list is empty.
3. Create a new wallet, or restore one from the 24-word phrase.
4. Write the phrase down offline. The wallet cannot recover funds from the phrase if you never saved it.
5. Wait until the wallet height matches the node. Coinbase outputs spend after 10 confirmations. A coinstake also needs to age 10 blocks.

On Linux the default data directory is `~/.PDC`. On macOS it is `~/Library/Application Support/PDC`. On 64-bit Windows it is the roaming application data folder named `PDC`. Override it with `--data-dir`.

## Check that you are on the right chain

The genesis hash must be:

```text
df35cba557c857756f20612ce3c9d2aa315d0ae8fc2aaffe6c5c59d37e00b10a
```

You can also open [the block explorer](https://explorer.privacydatacoin.com/) and compare the height with your node. The explorer is a view of public data. It does not reveal wallet transfers.

## A first command-line session

From the directory that contains the binaries:

```text
./daemon
```

In another terminal, against the default RPC at `127.0.0.1:19211`:

```text
./simplewallet --generate-new-wallet=mywallet --daemon-address=127.0.0.1:19211
```

Inside the wallet, `help` lists every command. `address` prints the `Px` address. `balance` shows whitelisted assets. `refresh` pulls new blocks.

> The exact generate-wallet flag follows the binary's `--help` text. If a flag name differs in a build, trust `simplewallet --help` over a remembered example. The commands inside a running wallet are the handlers in `src/simplewallet/simplewallet.cpp`.
