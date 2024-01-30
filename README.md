# Valuefy
A collection of three DEFI contracts, namely Staking, Lending Pool, and Vault, which are required as the first step in developing a DEFI protocol.

### Lending Pool Contract

Create a pool contract that accepts deposit from lenders and borrow money to the borrowers

- Lenders can lend any amount of money and earn some interest for it.
- User or borrower can borrow some amount of tokens (limited) , and pay back with interest for some time period.
- Interest is calculated according the interest rate and borrowing time peroid
- Lender can withdraw the amount later with extra interest earning
- Other functions can be called to determine the balance at any point of time , and the rewards earned

### Vault Contract

Sharing of Yield For the no. of shares owned

- user can deposit their money
- Some shares are minted according to the value deposited
- Vault generate some yield by a puropose and the value of share increases
- user can withdraw the amount by burning those share at any point of time .

### Staking Contract

Rewards user for staking their tokens in the contract

- User can withdraw and deposit at an point of time
- Tokens Earned can be withdrawed any time
- Rewards are calculated with reward rate and time period staked for
- The balance and reward earned can be checked at any point of time

### Inspiration
- Sui is a blockchain focused on mainstream adoption, and we are developing DEFI contracts to elevate Sui's mission to the next level of DEFI. We hope to make this the best library for DEFI contracts on the Sui Blockchain.

### The problem we're solving
- The project aims to address the need for DEFI (Decentralized Finance) capabilities on the Sui blockchain platform. DEFI has gained significant popularity in the blockchain space, offering various financial services such as lending, borrowing, staking, and more, without the need for intermediaries.
- The importance of tackling this problem lies in the growing demand for DEFI services and the potential impact it can have on the blockchain ecosystem. DEFI provides financial inclusivity, accessibility, and transparency to individuals worldwide, empowering them to participate in decentralized financial activities.
- By developing a collection of DEFI contracts, including a lending pool, a vault, and staking, the project aims to provide the foundation for a robust DEFI ecosystem on Sui. This not only benefits existing developers and users but also attracts new participants to the Sui network, increasing its adoption and expanding its use cases.

### Technoligies used
- Move Languag
- Sui Blockchain 
.

## Setup

### Prerequisites
Before we proceed, we should install a couple of things. Also, if you are using a Windows machine, it's recommended to use WSL2.

On Ubuntu/Debian/WSL2(Ubuntu):
```
sudo apt update
sudo apt install curl git-all cmake gcc libssl-dev pkg-config libclang-dev libpq-dev build-essential -y
```
On MacOs:
```
brew install curl cmake git libpq
```
If you don't have `brew` installed, run this:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Next, we need rust and cargo:
```
curl https://sh.rustup.rs -sSf | sh
```

### Install Sui
If you are using Github codespaces, it's recommended to use pre-built binaries rather than building them from source.

To download pre-built binaries, you should run `download-sui-binaries.sh` in the terminal. 
This scripts takes three parameters (in this particular order) - `version`, `environment` and `os`:
- sui version, for example `1.15.0`. You can lookup a more up-to-date version available here [SUI Github releases](https://github.com/MystenLabs/sui/releases).
- `environment` - that's the environment that you are targeting, in our case it's `devnet`. Other available options are: `testnet` and `mainnet`.
- `os` - name of the os. If you are using Github codespaces, put `ubuntu-x86_64`. Other available options are: `macos-arm64`, `macos-x86_64`, `ubuntu-x86_64`, `windows-x86_64` (not for WSL).

To donwload SUI binaries for codespace, run this command:
```
./download-sui-binaries.sh "v1.15.0" "devnet" "ubuntu-x86_64"
```
and restart your terminal window.

If you prefer to build the binaries from source, run this command in your terminal:
```
cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui
```

### Install dev tools (not required, might take a while when installin in codespaces)
```
cargo install --git https://github.com/move-language/move move-analyzer --branch sui-move --features "address32"

```

### Run a local network
To run a local network with a pre-built binary (recommended way), run this command:
```
RUST_LOG="off,sui_node=info" sui-test-validator
```

Optionally, you can run it from sources.
```
git clone --branch devnet https://github.com/MystenLabs/sui.git

cd sui

RUST_LOG="off,sui_node=info" cargo run --bin sui-test-validator
```

### Install SUI Wallet (optionally)
```
https://chrome.google.com/webstore/detail/sui-wallet/opcgpfmipidbgpenhmajoajpbobppdil?hl=en-GB
```

### Configure connectivity to a local node
Once the local node is running (using `sui-test-validator`), you should the url of a local node - `http://127.0.0.1:9000` (or similar).
Also, another url in the output is the url of a local faucet - `http://127.0.0.1:9123`.

Next, we need to configure a local node. To initiate the configuration process, run this command in the terminal:
```
sui client active-address
```
The prompt should tell you that there is no configuration found:
```
Config file ["/home/codespace/.sui/sui_config/client.yaml"] doesn't exist, do you want to connect to a Sui Full node server [y/N]?
```
Type `y` and in the following prompts provide a full node url `http://127.0.0.1:9000` and a name for the config, for example, `localnet`.

On the last prompt you will be asked which key scheme to use, just pick the first one (`0` for `ed25519`).

After this, you should see the ouput with the wallet address and a mnemonic phrase to recover this wallet. You can save so later you can import this wallet into SUI Wallet.

Additionally, you can create more addresses and to do so, follow the next section - `Create addresses`.


### Create addresses
For this tutorial we need two separate addresses. To create an address run this command in the terminal:
```
sui client new-address ed25519
```
where:
- `ed25519` is the key scheme (other available options are: `ed25519`, `secp256k1`, `secp256r1`)

And the output should be similar to this:
```
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Created new keypair and saved it to keystore.                                                   │
├────────────────┬────────────────────────────────────────────────────────────────────────────────┤
│ address        │ 0x05db1e318f1e4bc19eb3f2fa407b3ebe1e7c3cd8147665aacf2595201f731519             │
│ keyScheme      │ ed25519                                                                        │
│ recoveryPhrase │ lava perfect chef million beef mean drama guide achieve garden umbrella second │
╰────────────────┴────────────────────────────────────────────────────────────────────────────────╯
```
Use `recoveryPhrase` words to import the address to the wallet app.


### Get localnet SUI tokens
```
curl --location --request POST 'http://127.0.0.1:9123/gas' --header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "<ADDRESS>"
    }
}'
```
`<ADDRESS>` - replace this by the output of this command that returns the active address:
```
sui client active-address
```

You can switch to another address by running this command:
```
sui client switch --address <ADDRESS>
```
abd run the HTTP request to mint some SUI tokens to this account as well.

Also, you can top up the balance via the wallet app. To do that, you need to import an account to the wallet.

## Build and publish a smart contract

### Build package
To build tha package, you should run this command:
```
sui move build
```