#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--test-db --restart-chain]

    Options:
        --test-db:                use test db
        --restart-chain:      restart the substrate node
USAGE
  exit 1
}

TEST_DB=false
RESTART_CHAIN=false

for arg in "$@"; do
  case $arg in
  --test-db)
    TEST_DB=true
    shift # Remove --install from `$@`
    ;;
  --restart-chain)
    RESTART_CHAIN=true
    shift # Remove --install from `$@`
    ;;
  -h | --help)
    usage # run usage function on help
    ;;
  *)
    usage # run usage function if wrong argument provided
    ;;
  esac
done

# restart chain with no data
if [[ $RESTART_CHAIN == true || $TEST_DB == true ]]; then
  rm -rf ./chain-data
fi

SUBSTRATE_CONTAINER_NAME=$(docker ps -q -f name=substrate-node)
if [ -z "$SUBSTRATE_CONTAINER_NAME" ]; then
  echo "Substrate container not found, exiting"
fi

echo "Waiting for the substrate node to start up..."
# switch db
# TODO test this is working
if [[ $TEST_DB == true ]]; then
  cp -r .chain-test/. ./chain-data
fi


# Mac OSX cannot curl docker container https://stackoverflow.com/a/45390994/1178971
if [[ "$OSTYPE" == "darwin"* ]]; then
  SUBSTRATE_CONTAINER_IP="0.0.0.0"
else
  SUBSTRATE_CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$SUBSTRATE_CONTAINER_NAME")
fi

rpc_methods() {
  RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "rpc_methods"}' "$SUBSTRATE_CONTAINER_IP":9933/)
}

echo "Substrate container IP: $SUBSTRATE_CONTAINER_IP"
API_TRIES=0
rpc_methods
while [ "$RESPONSE_CODE" != 200 ]; do
  echo "Substrate API Response code: $RESPONSE_CODE"
  rpc_methods
  ((API_TRIES = API_TRIES + 1))
  if [ "$API_TRIES" -gt 10 ]; then
    echo "Could not reach Substrate API. Terminating process."
    exit 1
  fi
  sleep 1
done
