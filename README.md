# Integration
Integrates [protocol](https://github.com/prosopo-io/protocol/), [provider](https://github.com/prosopo-io/provider), and [dapp-example](https://github.com/prosopo-io/dapp-example) for development purposes

# Prerequisites
- ability to run bash scripts
- docker (tested on v20.10.8 / v20.10.11, used 4CPUs, 6GB of memory, 2GB of swap)

# Usage

## Make Setup

Start by pulling submodules using

`make setup`

## Make Dev

Create the dev docker containers using `make dev`

```bash
make dev install build-provider deploy-protocol deploy-dapp build-redspot
```

`make dev` will always perform the following tasks:

1. Creates and starts a substrate node container
2. Creates and starts up a mongodb container
3. Creates and starts up a provider container and connects to it in `zsh` shell at `/usr/src/

### Flags

The following flags are optional

| Flag            | Description |
|-----------------| --------------- |
| `build_redspot` | Builds the custom Prosopo redspot repository |
| `install` | Install the workspace dependencies |
| `deploy_protocol` | Deploy the Prosopo protocol contract to the Substrate node and stores `CONTRACT_ADDRESS` in `.env`|
| `deploy_dapp` | Deploy an example dapp contract to the Substrate node and stores `DAPP_CONTRACT_ADDRESS` in `.env`|
| `build_provider` | Generates a `PROVIDER_MNEMONIC` in `.env`, builds the provider repo, gives the provider funds, and registers them in the Prosopo contract|

### Provider Container

Once `make dev` is complete, you will be in a shell in the provider container `/usr/src/`, which is the root of the integration repo.

Dependencies should have been installed but you can install the dependencies using the following command if they are missing:

```bash
cd /usr/src/ && yarn
```

If you ran `build_provider`, default dev data will be populated in the contract - one registered Provider and one Dapp. There will also be default captcha data in the mongoDB.

Now you can interact with the provider CLI, start the API server, or run the tests.

## Tests

> Please note your `PROVIDER_MNEMONIC` environment variable must be set for the tests to run. You can check this with `echo $PROVIDER_MNEMONIC`

The provider tests can now be run from inside the container using

```bash
cd ./packages/provider/packages/core && yarn test
```

## Command Line Interface

First, `cd` into the `core` package.

```bash
cd ./packages/provider/packages/core
```

Then you will be able to run the following commands.

### Register a provider

```bash
yarn start provider_register --fee=10 --serviceOrigin=https://localhost:8282 --payee=Provider --address ADDRESS
```

| Param | Description |
| --------------- | --------------- |
| Fee | The amount the Provider charges or pays per captcha approval / disapproval |
| serviceOrigin | The location of the Provider's service |
| Payee | Who is paid on successful captcha completion (`Provider` or `Dapp`) |
| Address | Address of the Provider |

### Update a provider

```bash
yarn start provider_update --fee=10 --serviceOrigin=https://localhost:8282 --payee=Provider --address ADDRESS
```

Params are the same as `provider_register`

### Add a dataset for a Provider

```bash
yarn start provider_add_data_set --file /usr/src/data/captchas.json
```

| Param | Description |
| --------------- | --------------- |
| File | JSON file containing captchas |

File format can be viewed [here](https://github.com/prosopo-io/provider/blob/master/tests/mocks/data/captchas.json).

### De-register a Provider

```bash
yarn start provider_deregister --address ADDRESS
```

| Param | Description |
| --------------- | --------------- |
| Address | Address of the Provider |

### Unstake funds

```bash
yarn start provider_unstake --value VALUE
```

| Param | Description |
| --------------- | --------------- |
| Value | The amount of funds to unstake from the contract |

### List Provider accounts in contract

```bash
yarn start provider_accounts
```



## API

Run the API server

```bash
yarn start --api
```

The API contains functions that will be required for the frontend captcha interface.

| API Resource                                                        | Function |
|---------------------------------------------------------------------| --------------- |
| `/v1/prosopo/random_provider/`                                      | Get a random provider based on AccountId |
| `/v1/prosopo/providers/`                                            | Get list of all provider IDs |
| `/v1/prosopo/dapps/`                                                | Get list of all dapp IDs |
| `/v1/prosopo/provider/:providerAccount`                             | Get details of a specific Provider account |
| `/v1/prosopo/provider/captcha/:datasetId/:userAccount/:blockNumber` | Get captchas to solve |
| `/v1/prosopo/provider/solution`                                     | Submit captcha solutions |


## Dev Setup Script
The following commands can be run during development to populate the contract with dummy data.

| Command | Function | Executed during `make dev` |
| --------------- | --------------- | --------------- |
| Dev command to setup the provider stored in the env variable `PROVIDER_MNEMONIC` with dummy data |`yarn setup provider` | 🗸 |
| Dev command to setup the dapp contract stored in the env variable `DAPP_CONTRACT_ADDRESS` |`yarn setup dapp` | 🗸 |
| Dev command to respond to captchas from a `DAPP_USER` |`yarn setup user` | ✗ |
| Dev command to respond to captchas from a `DAPP_USER`, using the registered Provider to approve the response |`yarn setup user --approve` | ✗ |
| Dev command to respond to captchas from a `DAPP_USER`, using the registered Provider to disapprove the response |`yarn setup user --disapprove` | ✗ |
