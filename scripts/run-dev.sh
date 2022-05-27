#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--option]

    Options:
        --install-packages:   install all yarn packages
        --build-substrate:    rebuild the substrate image from scratch
        --build-provider:     build the provider library and setup dummy data
        --deploy-protocol:    deploy the prosopo protocol contract
        --deploy-dapp:        deploy the dapp-example contract
        --restart-chain:      restart the substrate chain
        --test-db:            start substrate container and the database container with test dbs
USAGE
  exit 1
}

# Flags
INSTALL_PACKAGES=false
BUILD_SUBSTRATE=false
BUILD_PROVIDER=false
DEPLOY_PROTOCOL=false
DEPLOY_DAPP=false
RESTART_CHAIN=false
TEST_DB=false
ENV_FILE=.env

for arg in "$@"; do
  echo "$arg"
  case $arg in
  --install)
    INSTALL_PACKAGES=true
    shift # Remove --install from `$@`
    ;;
  --build-substrate)
    BUILD_SUBSTRATE=true
    shift # Remove --build_substrate from `$@`
    ;;
  --restart-chain)
    RESTART_CHAIN=true
    shift # Remove --restart-chain from `$@`
    ;;
  --build-provider)
    BUILD_PROVIDER=true
    shift # Remove --build_provider from `$@`
    ;;
  --deploy-protocol)
    DEPLOY_PROTOCOL=true
    shift # Remove --deploy_protocol from `$@`
    ;;
  --deploy-dapp)
    DEPLOY_DAPP=true
    shift # Remove --deploy_dapp from `$@`
    ;;
  --test-db)
    TEST_DB=true
    shift # Remove --test-db from `$@`
    ;;
  -h | --help)
    usage # run usage function on help
    ;;
  *)
    usage # run usage function if wrong argument provided
    ;;
  esac
done

echo "INSTALL_PACKAGES: $INSTALL_PACKAGES"
echo "BUILD_PROVIDER:   $BUILD_PROVIDER"
echo "BUILD_SUBSTRATE:  $BUILD_SUBSTRATE"
echo "DEPLOY_PROTOCOL:  $DEPLOY_PROTOCOL"
echo "DEPLOY_DAPP:      $DEPLOY_DAPP"
echo "TEST_DB:          $TEST_DB"
echo "RESTART_CHAIN:    $RESTART_CHAIN"
echo "ENV_FILE:         $ENV_FILE"

# create an empty .env file
touch $ENV_FILE

# remove any duplicates in .env file
cat $ENV_FILE | uniq >$ENV_FILE.tmp
mv $ENV_FILE.tmp $ENV_FILE
source $ENV_FILE

# https://stackoverflow.com/questions/2320564/sed-i-command-for-in-place-editing-to-work-with-both-gnu-sed-and-bsd-osx/38595160#38595160
sedi() {
  sed --version >/dev/null 2>&1 && sed -i "$@" || sed -i "" "$@"
}

# spin up the substrate node
if [[ $BUILD_SUBSTRATE == true ]]; then
  docker compose up substrate-node -d --build
else
  docker compose up substrate-node -d --no-build
fi

# start the substrate process as a background task
START_SUBSTRATE_ARGS=()
if [[ $RESTART_CHAIN == true ]]; then
  START_SUBSTRATE_ARGS+=(--restart-chain)
fi
if [[ $TEST_DB == true ]]; then
  START_SUBSTRATE_ARGS+=(--test-db)
fi
./scripts/start-substrate.sh "${START_SUBSTRATE_ARGS[@]}" || exit 1

# start the database container
./scripts/start-db.sh --env-file=$ENV_FILE

docker compose up provider-api -d
CONTAINER_NAME=$(docker ps -q -f name=provider-api)

if [[ $TEST_DB == true ]]; then
  docker cp .database_accounts.json "$CONTAINER_NAME":/usr/src/database_accounts.json
fi

docker compose up contracts -d

if [[ $INSTALL_PACKAGES == true ]]; then
  docker exec -t "$CONTAINER_NAME" zsh -c 'cd /usr/src && yarn'
fi

if [[ $DEPLOY_PROTOCOL == true ]]; then
  DEPLOY_RESULT=$(./scripts/deploy-contract.sh \
    --contract-source="$PROTOCOL_CONTRACT_SOURCE" \
    --wasm="$PROTOCOL_WASM" \
    --constructor="$PROTOCOL_CONSTRUCTOR" \
    --contract-args="$PROTOCOL_CONTRACT_ARGS" \
    --endowment="$PROTOCOL_ENDOWMENT" \
    --endpoint="$SUBSTRATE_ENDPOINT" \
    --port="$SUBSTRATE_PORT" \
    --suri="$DEPLOYER_SURI" \
    --use-salt \
    --build)
  CONTRACT_ADDRESS=$(echo "$DEPLOY_RESULT" | tail -1)
  if [[ $CONTRACT_ADDRESS == "Contract failed to deploy" ]]; then
    echo "$DEPLOY_RESULT"
    exit 1
  fi
  echo "Protocol Contract Address: $CONTRACT_ADDRESS"
  # Put the contract address in the env file in various places
  grep -q "^CONTRACT_ADDRESS=.*" "$ENV_FILE" && sedi -e "s/^CONTRACT_ADDRESS=.*/CONTRACT_ADDRESS=$CONTRACT_ADDRESS/g" "$ENV_FILE" || echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >>"$ENV_FILE"
  grep -q "^REACT_APP_DAPP_CONTRACT_ADDRESS=.*" "$ENV_FILE" && sedi -e "s/^REACT_APP_DAPP_CONTRACT_ADDRESS=.*/REACT_APP_DAPP_CONTRACT_ADDRESS=$CONTRACT_ADDRESS/g" "$ENV_FILE" || echo "REACT_APP_DAPP_CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >>"$ENV_FILE"
  echo "$DAPP_CONTRACT_ARGS" && sedi -e "s/([[:alnum:]]{48})/$CONTRACT_ADDRESS/g" "$ENV_FILE"
fi

if [[ $DEPLOY_DAPP == true ]]; then
  # Make sure dapp args are up to date with most recent protocol contract address
  echo "$DAPP_CONTRACT_ARGS" && sedi -e "s/([[:alnum:]]{48})/$CONTRACT_ADDRESS/g" "$ENV_FILE"
  DEPLOY_RESULT=$(./scripts/deploy-contract.sh \
    --contract-source="$DAPP_CONTRACT_SOURCE" \
    --wasm="$DAPP_WASM" \
    --constructor="$DAPP_CONSTRUCTOR" \
    --contract-args="$DAPP_CONTRACT_ARGS" \
    --endowment="$DAPP_ENDOWMENT" \
    --endpoint="$SUBSTRATE_ENDPOINT" \
    --port="$SUBSTRATE_PORT" \
    --suri="$DEPLOYER_SURI" \
    --use-salt \
    --build)
  DAPP_CONTRACT_ADDRESS=$(echo "$DEPLOY_RESULT" | tail -1)
  if [[ $DAPP_CONTRACT_ADDRESS == "Contract failed to deploy" ]]; then
    echo "$DEPLOY_RESULT"
    exit 1
  fi
  echo "Dapp Example Contract Address: $DAPP_CONTRACT_ADDRESS"
  # Put the contract address in the env file
  grep -q "^DAPP_CONTRACT_ADDRESS=.*" "$ENV_FILE" && sedi -e "s/^DAPP_CONTRACT_ADDRESS=.*/DAPP_CONTRACT_ADDRESS=$DAPP_CONTRACT_ADDRESS/g" "$ENV_FILE" || echo "DAPP_CONTRACT_ADDRESS=$DAPP_CONTRACT_ADDRESS" >>"$ENV_FILE"
fi

echo "Linking artifacts to core package and contract package"
docker exec -it "$CONTAINER_NAME" zsh -c 'ln -sfn /usr/src/protocol/artifacts /usr/src/packages/provider/artifacts'
docker exec -it "$CONTAINER_NAME" zsh -c 'ln -sfn /usr/src/protocol/artifacts /usr/src/packages/contract/artifacts'

echo "Copy protocol/artifacts/prosopo.json to packages/contract/src/abi/prosopo.json"
docker exec -it "$CONTAINER_NAME" zsh -c 'cp -f /usr/src/protocol/artifacts/prosopo.json /usr/src/packages/contract/src/abi/prosopo.json'

if [[ $BUILD_PROVIDER == true ]]; then
  echo "Generating provider mnemonic"
  docker exec -it "$CONTAINER_NAME" zsh -c '/usr/src/docker/dev.dockerfile.generate.provider.mnemonic.sh /usr/src/protocol'
  echo "Sending funds to the Provider account and registering the provider"
  docker exec -it --env-file $ENV_FILE "$CONTAINER_NAME" zsh -c 'yarn && yarn build && cd /usr/src/packages/provider && yarn setup provider && yarn setup dapp'
fi

echo "Dev env up! You can now interact with the provider-api."
docker exec -it --env-file $ENV_FILE "$CONTAINER_NAME" zsh
