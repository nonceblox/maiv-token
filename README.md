# Maiv Smart Contracts

This repository provides a comprehensive development environment tailored for the Maiv Smart Contracts, leveraging
Foundry and a suite of development tools to facilitate a smooth development, testing, and deployment process.

## Features

- [Foundry](https://book.getfoundry.sh/): compile, run, test and deploy smart contracts
- [Solhint](https://github.com/protofire/solhint): to enforce code quality and conformity to Solidity best practices.
- [Prettier Plugin Solidity](https://github.com/prettier-solidity/prettier-plugin-solidity): Adopts Prettier with
  Solidity plugin for consistent code formatting, improving readability and maintainability.
- [Test Coverage](https://github.com/sc-forks/solidity-coverage): Utilize solidity-coverage to measure the coverage of
  your tests, ensuring comprehensive testing of contract functionalities.
- [Contract Sizing](https://github.com/ItsNickBarry/hardhat-contract-sizer): Includes tools to analyze and report the
  size of compiled smart contracts, aiding in optimization and gas usage estimation.


## Pre Requisites

Before diving into development, ensure you have the following tools and configurations set up:

- **Node.js and npm or bun**: Ensure you have Node.js and npm or bun installed to manage project dependencies.
- **Foundry**: Familiarize yourself with Foundry's workflow and commands for a smooth development experience.
- **Ethereum Wallet**: Have an Ethereum wallet setup, preferably with testnet Ether for deployment and testing.
- **Solidity Knowledge**: A good understanding of Solidity and smart contract development is essential.

## Usage

### Installation

1. **Clone the Repository**: Start by cloning this repository to your local machine.

```sh
git clone https://github.com/nonceblox/maiv-token
```

2. **Navigate to the project directory**

```sh
cd maiv-token
```

3. **setup environment**: create .env and copy from .env.example

```sh
PRIVATE_KEY=
ETHERSCAN_API_KEY=
SEPOLIA_RPC_URL=
```

4. **Forge dependencies Install**

```sh
forge install
```

5. **Node dependencies Install**: Install Solhint, Prettier, and other Node.js deps

```sh
bun install
```

or

```sh
npm install
```

### Compile

to build or compile

```sh
forge build
```

### Test

to run all the tests

```sh
forge test
```

### Coverage

```sh
forge coverage
```

### Solhint

```sh
npm run lint:sol
```

### Deploy

Before running the deployment script, ensure that all parameter values are assigned in the deployment script folder.

- **MaivToken.s.sol**: ownerAddress, initialHolderAddress, admin1, admin2, admin3

 **Deploy MaivToken.sol**

```sh
forge script script/MaivToken.s.sol:MaivTokenScript --rpc-url <your_rpc_url> --broadcast
```

### Clear

to clear build files

```sh
forge clean
```

### Format

```shell
forge fmt
```

### Gas Snapshots

```shell
forge snapshot
```

### Help

```shell
forge --help
anvil --help
cast --help
```
