# Integration
Integrates prosopo repositories in a development environment

- [protocol](https://github.com/prosopo-io/protocol/)
- [dapp-example](https://github.com/prosopo-io/dapp-example)
- [provider](https://github.com/prosopo-io/provider)
- [contract](https://github.com/prosopo-io/contract)
- [procaptcha](https://github.com/prosopo-io/procaptcha)
- [procaptcha-react](https://github.com/prosopo-io/procaptcha-react)
- [client-example](https://github.com/prosopo-io/client-example)

# Prerequisites
- ability to run bash scripts
- docker (tested on v20.10.8 / v20.10.11/ v20.10.14, used 4CPUs, 6GB of memory, 2GB of swap)
- [docker compose v2+](https://www.docker.com/blog/announcing-compose-v2-general-availability/)

# Usage

```bash
git clone git@github.com:prosopo-io/integration.git
````

## Make Setup

Start by pulling submodules and then updating them

`make setup && npm run git-sync`

## Make Dev

Deploy the [protocol](https://github.com/prosopo-io/protocol/) contract and [dapp-example](https://github.com/prosopo-io/dapp-example) contract to a local substrate node using the following command.

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

| Flag              | Description                                                                                            |
|-------------------|--------------------------------------------------------------------------------------------------------|
| `deploy-protocol` | Deploy the Prosopo protocol contract to the Substrate node and stores `CONTRACT_ADDRESS` in `.env`     |
| `deploy-dapp`     | Deploy an example dapp contract to the Substrate node and stores `DAPP_CONTRACT_ADDRESS` in `.env`     |
| `restart-chain`   | Start with a fresh version of the substrate node with an empty chain. Contracts will need re-deployed. |
| `test-db`         | Start substrate container and the database container with test dbs                                     |



## Development Environment Setup
The following command can be run during development to populate the contract with dummy data.
- TODO...
`npm run populate-data`

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
