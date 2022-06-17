# Integration
Integrates prosopo repositories in a development environment

- [protocol](https://github.com/prosopo-io/protocol/)
- [dapp-example](https://github.com/prosopo-io/dapp-example)
- [provider](https://github.com/prosopo-io/provider)
- [contract](https://github.com/prosopo-io/contract)
- [procaptcha](https://github.com/prosopo-io/procaptcha)
- [procaptcha-react](https://github.com/prosopo-io/procaptcha-react)

# Prerequisites
- ability to run bash scripts
- docker (tested on v20.10.8 / v20.10.11/ v20.10.14, used 4CPUs, 6GB of memory, 2GB of swap)
- [docker compose v2+](https://www.docker.com/blog/announcing-compose-v2-general-availability/)

# Usage

## Make Setup

Start by pulling submodules using

`make setup`

## Make Dev

Pull the docker containers using the following command

```bash
make dev deploy-protocol deploy-dapp
```

This does the following:

1. Pulls and starts a substrate node container.
2. Pulls and starts up a mongodb container.
3. Pulls a contract build and deploy container for protocol and deploys the contract to the substrate node. The contract account is stored in `.env.protocol`.
4. Pulls a contract build and deploy container for dapp-example and deploys the contract to the substrate node. The contract account is stored in `.env.dapp`.
5. Creates a new `.env` file from `env.txt` and places the two contract addresses in this new `.env` file.

### Flags

The following flags are optional

| Flag              | Description                                                                                        |
|-------------------|----------------------------------------------------------------------------------------------------|
| `deploy-protocol` | Deploy the Prosopo protocol contract to the Substrate node and stores `CONTRACT_ADDRESS` in `.env` |
| `deploy-dapp`     | Deploy an example dapp contract to the Substrate node and stores `DAPP_CONTRACT_ADDRESS` in `.env` |
| `restart-chain`   | Start with a fresh version of the substrate node with an empty chain                               |
| `test-db`         | Start substrate container and the database container with test dbs                                 |

### Provider Node

TODO

## Tests

> Please note your `PROVIDER_MNEMONIC` environment variable must be set for the tests to run. You can check this with `echo $PROVIDER_MNEMONIC`

The provider tests can now be run from inside the provider repo using

```bash
cd ./packages/provider && yarn test
```

## Command Line Interface

From within the provider package the following commands are available.

### Register a provider

```bash
yarn provider provider_register --fee=10 --serviceOrigin=https://localhost:8282 --payee=Provider --address ADDRESS
```

| Param | Description |
| --------------- | --------------- |
| Fee | The amount the Provider charges or pays per captcha approval / disapproval |
| serviceOrigin | The location of the Provider's service |
| Payee | Who is paid on successful captcha completion (`Provider` or `Dapp`) |
| Address | Address of the Provider |

### Update a provider

```bash
yarn provider provider_update --fee=10 --serviceOrigin=https://localhost:8282 --payee=Provider --address ADDRESS
```

Params are the same as `provider_register`

### Add a dataset for a Provider

```bash
yarn provider provider_add_data_set --file /usr/src/data/captchas.json
```

| Param | Description |
| --------------- | --------------- |
| File | JSON file containing captchas |

File format can be viewed [here](https://github.com/prosopo-io/provider/blob/master/tests/mocks/data/captchas.json).

### De-register a Provider

```bash
yarn provider provider_deregister --address ADDRESS
```

| Param | Description |
| --------------- | --------------- |
| Address | Address of the Provider |

### Unstake funds

```bash
yarn provider provider_unstake --value VALUE
```

| Param | Description |
| --------------- | --------------- |
| Value | The amount of funds to unstake from the contract |

### List Provider accounts in contract

```bash
yarn provider provider_accounts
```

## API

Run the API server

```bash
yarn start
```

The API contains functions that will be required for the frontend captcha interface.

| API Resource                                                        | Function                                   |
|---------------------------------------------------------------------|--------------------------------------------|
| `/v1/prosopo/random_provider/`                                      | Get a random provider based on AccountId   |
| `/v1/prosopo/providers/`                                            | Get list of all provider IDs               |
| `/v1/prosopo/dapps/`                                                | Get list of all dapp IDs                   |
| `/v1/prosopo/provider/:providerAccount`                             | Get details of a specific Provider account |
| `/v1/prosopo/provider/captcha/:datasetId/:userAccount/:blockNumber` | Get captchas to solve                      |
| `/v1/prosopo/provider/solution`                                     | Submit captcha solutions                   |


## Development Environment Setup
The following commands can be run during development to populate the contract with minimal dummy data.

| Command                                                                                                         | Function                       |
|-----------------------------------------------------------------------------------------------------------------|--------------------------------|
| Dev command to setup the provider stored in the env variable `PROVIDER_MNEMONIC` with dummy data                | `yarn setup provider`          |
| Dev command to setup the dapp contract stored in the env variable `DAPP_CONTRACT_ADDRESS`                       | `yarn setup dapp`              |
| Dev command to respond to captchas from a `DAPP_USER`                                                           | `yarn setup user`              |
| Dev command to respond to captchas from a `DAPP_USER`, using the registered Provider to approve the response    | `yarn setup user --approve`    |
| Dev command to respond to captchas from a `DAPP_USER`, using the registered Provider to disapprove the response | `yarn setup user --disapprove` |
| Dev command to populate the contract and database with *many* Providers and Dapps                               | `yarn populate-data`           |

### Development Debugging and Testing
When debugging the frontend you will only want 1 provider in the contract so that the random provider returned to you has a corresponding backend. The steps to achieve this are as follows:
- Run `make dev deploy-protocol deploy-dapp` in the integration root to deploy the contracts
- Run `yarn` in npm workspace to install all packages
- Run `TODO` in npm workspace to build packages and populate environment variables
- TODO...

### Populate Data
Dummy data can be populated in the protocol contract and provider database using the following steps. Snapshots of the substrate database, mongo database, and created accounts are then exported, ready to be used for testing in future.
- Create an *empty* environment (restart substrate chain and clear mongo database)
- Run `yarn populate-data` to populate the contract and database with *many* Providers and Dapps
  - Substrate chain data will be exported to `.chain-test` in the integration root
  - Mongo database data will be exported to `.db-test` in the integration root
  - Created account mnemonics will be exported to `.database_accounts.json`
- Remove your environment afterwards
  - To clear the substrate database run `make dev restart-chain`
  - To clear the mongo database run `docker container exec -it "$(docker ps -q -f name=provider-db)" bash -c "mongosh -u root -p root --authenticationDatabase admin prosopo --eval 'db.dropDatabase()'"`

### Running Tests with Populated Data
Once you have a saved copy of data, you can use it to run the tests with the following command

`yarn test:mock`

This performs the following steps:

- Restarts substrate using the `.chain-test` data directory
- Starts the mongo database loading the data in `.db-test` to the `DATABASE_NAME` specified in `.env.test`
- Copies `.database_accounts.json` to `database_accounts.json`
- Runs `yarn workspace @prosopo/provider run test:mock` in the provider package
- Restarts substrate with your original chain data
- Restarts the mongo database with your original database as specified in `DATABASE_NAME` in `.env`
