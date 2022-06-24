#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--option]

    Options:
        --build-substrate:    rebuild the substrate image from scratch
        --restart-chain:      restart the substrate chain
        --test-db:            start substrate container and the database container with test dbs
        --env:                demo | test | ...
USAGE
  exit 1
}

# Flags
BUILD_SUBSTRATE=false
RESTART_CHAIN=false
TEST_DB=false
ENV_FILE=.env

for arg in "$@"; do
  echo "$arg"
  case $arg in
  --build-substrate)
    BUILD_SUBSTRATE=true
    shift # Remove --build_substrate from `$@`
    ;;
  --restart-chain)
    RESTART_CHAIN=true
    shift # Remove --restart-chain from `$@`
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

echo "BUILD_SUBSTRATE:  $BUILD_SUBSTRATE"
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

# Put the new contract addresses in a new .env file based on a template .env.txt
PROTOCOL_CONTRACT_ADDRESS=$(echo "$(<$ENV_FILE.contract.protocol)" | cut -d '=' -f2) || false
DAPP_CONTRACT_ADDRESS=$(echo "$(<$ENV_FILE.contract.dapp)" | cut -d '=' -f2) || false
DEMO_CONTRACT_ADDRESS=$(echo "$(<$ENV_FILE.contract.demo)" | cut -d '=' -f2) || false
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

echo "Dev env up!"
exit 0
