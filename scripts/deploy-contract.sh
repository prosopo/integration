#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--option]

    Options:
        --contract-source:  folder containing the contract source
        --wasm:             path to wasm from source folder
        --constructor:      name of the contract constructor function
        --contract-args:    args for the contract constructor
        --endowment:        funds given to the contract
        --endpoint:         substrate endpoint
        --port:             port of substrate endpoint
        --suri:             substrate uri / mnemonic
        --env-file:         env file in which to populate the contract address
        --env-var:          env variable name
        --use-salt:         use a unique salt to prevent duplicate contracts
        --build:            build the contract before deploying

USAGE
  exit 1
}

# Default args
CONTRACT_SOURCE=""
WASM=""
CONSTRUCTOR="new"
CONTRACT_ARGS=""
ENDOWMENT="10000000000000"
ENDPOINT="0.0.0.0"
PORT="9944"
SURI=""
ENV_FILE=".env"
USE_SALT=false
BUILD=false

for arg in "$@"; do
  echo "$arg"
  case $arg in
  --contract-source*)
    CONTRACT_SOURCE=$(echo $1 | sed -e 's/^[^=]*=//g')
    shift # Remove --contract-source from `$@`
    ;;
  --wasm*)
    WASM=$(echo $1 | sed -e 's/^[^=]*=//g')
    shift # Remove --wasm from `$@`
    ;;
  --constructor*)
    CONSTRUCTOR=$(echo $1 | sed -e 's/^[^=]*=//g')
    shift # Remove --constructor from `$@`
    ;;
  --contract-args*)
    CONTRACT_ARGS=$(echo $1 | sed -e 's/^[^=]*=//g')
    shift # Remove --contract-args from `$@`
    ;;
  --endowment*)
    ENDOWMENT=$(echo $1 | sed -e 's/^[^=]*=//g')
    shift # Remove --endowment from `$@`
    ;;
  --endpoint*)
    ENDPOINT=$(echo $1 | sed -e 's/^[^=]*=//g')
    shift # Remove --endpoint from `$@`
    ;;
  --port*)
    PORT=$(echo $1 | sed -e 's/^[^=]*=//g')
    shift # Remove --port from `$@`
    ;;
  --suri*)
    SURI=$(echo $1 | sed -e 's/^[^=]*=//g')
    shift # Remove --suri from `$@`
    ;;
  --use-salt)
    USE_SALT=true
    shift # Remove --use-salt from `$@`
    ;;
  --build)
    BUILD=true
    shift # Remove --build from `$@`
    ;;
  esac
done

CONTRACTS_CONTAINER=$(docker ps -q -f name=integration-contracts)
echo "Container id:     $CONTRACTS_CONTAINER"
echo "Contract Source:  $CONTRACT_SOURCE"

if [[ $BUILD == true ]]; then
  echo "Building contract"
  docker exec -t "$CONTRACTS_CONTAINER" bash -c "cd $CONTRACT_SOURCE && cargo +nightly contract build"
fi

#echo "Source is $CONTRACT_SOURCE"

CMD="cd $CONTRACT_SOURCE && cargo contract instantiate $WASM --args $CONTRACT_ARGS --constructor $CONSTRUCTOR --suri $SURI --value $ENDOWMENT --url '$ENDPOINT:$PORT'"

CMDSALT="$CMD"
if [[ $USE_SALT == true ]]; then
  SALT=$(date | sha256sum | cut -b 1-64)
  CMDSALT="$CMD --salt $SALT"
fi

DEPLOY_RESULT=$(docker exec "$CONTRACTS_CONTAINER" bash -c "$CMDSALT")

if [[ $(echo "$DEPLOY_RESULT" | grep 'ExtrinsicSuccess' | wc -l) == 1 ]]; then
  CONTRACT_ADDRESS=$(echo "$DEPLOY_RESULT" | grep 'who: [A-Za-z0-9]*' | tail -1 | tr "[:space:]" '\n' | tail -1)
  echo "$CONTRACT_ADDRESS"
else
  echo "Contract failed to deploy"
  exit 1
fi
