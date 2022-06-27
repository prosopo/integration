# Integration
Integrates prosopo repositories in a development environment

- [protocol](https://github.com/prosopo-io/protocol/)
- [provider](https://github.com/prosopo-io/provider)
- [contract](https://github.com/prosopo-io/contract)
- [procaptcha](https://github.com/prosopo-io/procaptcha)
- [procaptcha-react](https://github.com/prosopo-io/procaptcha-react)
- [client-example](https://github.com/prosopo-io/client-example)
- [demo-nft-marketplace](https://github.com/prosopo-io/demo-nft-marketplace)
- [dapp-example](https://github.com/prosopo-io/dapp-example)

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

| Flag              | Description                                                                    |
|-------------------|--------------------------------------------------------------------------------|
| `restart-chain`   | Restart the substrate container, deleting any data that was added to contracts |
| `test-db`         | Start substrate container and the database container with test dbs             |

## Development Environment Setup

### Debugging and Testing
To bebug a frontend dapp, register a provider and a dapp in the [protocol](https://github.com/prosopo-io/protocol/) contract. The steps to achieve this are as follows:

```bash
npm run setup
```

Start the captcha challenge API by running the following command

```bash
npm run start
```

You can then start one of the frontend demos to begin receiving captchas in the browser. See the READMEs in each of the demos for information on how to run them.

- [demo-nft-marketplace](https://github.com/prosopo-io/demo-nft-marketplace) (full marketplace)
- [client-example](https://github.com/prosopo-io/client-example) (minimal implementation)


### Running Tests
Tests are executed on a test docker container with pre-deployed, pre-populated contracts. This container is started when the following command is run:

`npm run test`

The tests are run from the provider repository.
