#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--option]

    Options:
        --install-packages:   install all yarn packages
        --build-substrate:    rebuild the substrate image from scratch
        --deploy-protocol:    deploy the prosopo protocol contract
        --deploy-dapp:        deploy the dapp-example contract
        --deploy-demo:        deploy the dapp-nft-marketplace contract
        --restart-chain:      restart the substrate chain
        --test-db:            start substrate container and the database container with test dbs
USAGE
  exit 1
}

# Flags
INSTALL_PACKAGES=false
BUILD_SUBSTRATE=false
DEPLOY_PROTOCOL=false
DEPLOY_DAPP=false
DEPLOY_DEMO=false
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
  --deploy-protocol)
    DEPLOY_PROTOCOL=true
    shift # Remove --deploy_protocol from `$@`
    ;;
  --deploy-dapp)
    DEPLOY_DAPP=true
    shift # Remove --deploy_dapp from `$@`
    ;;
  --deploy-demo)
    DEPLOY_DEMO=true
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
echo "BUILD_SUBSTRATE:  $BUILD_SUBSTRATE"
echo "DEPLOY_PROTOCOL:  $DEPLOY_PROTOCOL"
echo "DEPLOY_DAPP:      $DEPLOY_DAPP"
echo "DEPLOY_DEMO:      $DEPLOY_DEMO"
echo "TEST_DB:          $TEST_DB"
echo "RESTART_CHAIN:    $RESTART_CHAIN"
echo "ENV_FILE:         $ENV_FILE"

# create an empty .env file
touch $ENV_FILE

# remove any duplicates in .env file
cat $ENV_FILE | uniq >$ENV_FILE.tmp
mv $ENV_FILE.tmp $ENV_FILE

# create a new version of the .env based on a template
cp "${ENV_FILE:1}".txt $ENV_FILE
cp "${ENV_FILE:1}".demo.txt $ENV_FILE.demo
cp "${ENV_FILE:1}".dapp.txt $ENV_FILE.dapp
cp "${ENV_FILE:1}".protocol.txt $ENV_FILE.protocol

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

if [[ $DEPLOY_PROTOCOL == true ]]; then
  docker compose up protocol-build
  PROTOCOL_CONTAINER_NAME=$(docker ps -qa -f name=protocol | head -n 1)
  docker cp "$PROTOCOL_CONTAINER_NAME:/usr/src/.env" "$ENV_FILE.protocol" || exit 1
  # TODO: Remove. Temporarily replicating redspot functionality so script continues to function
  mkdir -p ./protocol/artifacts
  docker cp "$PROTOCOL_CONTAINER_NAME:/usr/src/protocol/contracts/target/ink/metadata.json" ./protocol/artifacts/prosopo.json || exit 1
  docker cp "$PROTOCOL_CONTAINER_NAME:/usr/src/protocol/contracts/target/ink/prosopo.contract" ./protocol/artifacts/prosopo.contract || exit 1
  docker cp "$PROTOCOL_CONTAINER_NAME:/usr/src/protocol/contracts/target/ink/prosopo.wasm" ./protocol/artifacts/prosopo.wasm || exit 1
fi

if [[ $DEPLOY_DAPP == true ]]; then
  docker compose run -e "$(cat "$ENV_FILE.protocol")" dapp-build /usr/src/docker/contracts.deploy.dapp.sh
  DAPP_CONTAINER_NAME=$(docker ps -qa -f name=dapp | head -n 1)
  docker cp "$DAPP_CONTAINER_NAME:/usr/src/.env" "$ENV_FILE.dapp" || echo "ERROR: Failed to copy .env file from container $DAPP_CONTAINER_NAME"
fi

if [[ $DEPLOY_DEMO == true ]]; then
  docker compose run -e "$(cat "$ENV_FILE.protocol")" demo-build /usr/src/docker/contracts.deploy.demo.sh
  DEMO_CONTAINER_NAME=$(docker ps -qa -f name=demo | head -n 1)
  docker cp "$DEMO_CONTAINER_NAME:/usr/src/.env" "$ENV_FILE.demo"
fi

# Put the new contract addresses in a new .env file based on a template .env.txt
PROTOCOL_CONTRACT_ADDRESS=$(echo "$(<$ENV_FILE.protocol)" | cut -d '=' -f2) || false
DAPP_CONTRACT_ADDRESS=$(echo "$(<$ENV_FILE.dapp)" | cut -d '=' -f2) || false
DEMO_CONTRACT_ADDRESS=$(echo "$(<$ENV_FILE.demo)" | cut -d '=' -f2) || false
echo "PROTOCOL_CONTRACT_ADDRESS $PROTOCOL_CONTRACT_ADDRESS"
echo "DAPP_CONTRACT_ADDRESS     $DAPP_CONTRACT_ADDRESS"
echo "DEMO_CONTRACT_ADDRESS     $DEMO_CONTRACT_ADDRESS"
if [[ $PROTOCOL_CONTRACT_ADDRESS ]]; then
  sed -e "s/%CONTRACT_ADDRESS%/$PROTOCOL_CONTRACT_ADDRESS/g" $ENV_FILE > $ENV_FILE.new && mv $ENV_FILE.new $ENV_FILE || echo "ERROR: Invalid contract address - '$CONTRACT_ADDRESS'"
fi
if [[ $DAPP_CONTRACT_ADDRESS ]]; then
  sed -e "s/%DAPP_CONTRACT_ADDRESS%/$DAPP_CONTRACT_ADDRESS/g" $ENV_FILE > $ENV_FILE.new && mv $ENV_FILE.new $ENV_FILE || echo "ERROR: Invalid dapp contract address - '$DAPP_CONTRACT_ADDRESS'"
fi
if [[ $DEMO_CONTRACT_ADDRESS ]]; then
  sed -e "s/%DEMO_CONTRACT_ADDRESS%/$DEMO_CONTRACT_ADDRESS/g" $ENV_FILE > $ENV_FILE.new && mv $ENV_FILE.new $ENV_FILE || echo "ERROR: Invalid dapp contract address - '$DEMO_CONTRACT_ADDRESS'"
fi
# TODO: move .env to .env.dev.

echo "Dev env up!"
exit 0
# docker exec -it --env-file $ENV_FILE "$CONTAINER_NAME" zsh
