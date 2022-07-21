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

## Development Environment Set Up

The following instructions explain how to set up a developer environment in which changes can be made to the various JavaScript packages.


### Pull Submodules

Start by pulling submodules. Run the following command from the root of the integration repository.

```bash
git submodule update --init --recursive --force --checkout
```

### Set up Containers

Setup your integration containers by running the following command from the root of the integration repository.

```bash
docker compose --file docker-compose.development.yml up -d
```

This does the following:

1. Pulls and starts a substrate node container containing pre-deployed [protocol](https://github.com/prosopo-io/protocol/), [dapp-example](https://github.com/prosopo-io/dapp-example), and [demo-nft-marketplace](https://github.com/prosopo-io/demo-nft-marketplace) contracts.
2. Pulls and starts up a mongodb container.

### Install node modules

Install the node modules and build the workspace by running the following command from the root of the integration repository.

```bash
npm i && npm run build
```

### Set up a Provider

Providers are the nodes in the network that supply CATPCHA. Run the following command from the root of the integration repository to register a Provider and a Dapp in the Protocol contract and start the Provider API.

```bash
cd packages/provider && \
npm run setup && \
npm run start
```

You can simply run `npm run start` on subsequent runs.

#### Command Details
| Command         | Description                                                |
|-----------------|------------------------------------------------------------|
| `npm run setup` | Registers the Provider and a Dapp in the Protocol contract |
| `npm run start` | Starts the provider API                                    |

### Debugging and Testing a Frontend App

You can now start one of the frontend demos to begin receiving CAPTCHA challenges in the browser. See the READMEs in each of the demos for information on how to run them.

- [demo-nft-marketplace](https://github.com/prosopo-io/demo-nft-marketplace) (full marketplace)
- [client-example](https://github.com/prosopo-io/client-example) (minimal implementation)


### Running Tests

Set up the test environment by running the following command from the root of the integration repository.

```bash
docker compose --file docker-compose.test.yml up -d
```

Then run the tests from the provider repository.

```bash
cd packages/provider && \
npm run test`
```
