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

echo "Waiting for the substrate node to start up..."
SUBSTRATE_CONTAINER_NAME=$(docker ps -q -f name=substrate-node)
if [ -z "$SUBSTRATE_CONTAINER_NAME" ]; then
  echo "Substrate container not running, exiting"
  exit 1
fi

SUBSTRATE_PID=$(docker exec $SUBSTRATE_CONTAINER_NAME sh -c "ps aux | grep -v grep | grep substrate-contracts-node | awk '{print \$2}'")
MAIN_PID=$(docker exec $SUBSTRATE_CONTAINER_NAME sh -c "ps -ef | grep \"0\ssleep infinity\" | awk 'FNR == 1 {print \$2}'")
# restart chain with no data
if [[ $RESTART_CHAIN == true || $TEST_DB == true ]]; then
  if [[ -n "$SUBSTRATE_PID" ]]; then
    for pid in $SUBSTRATE_PID; do
      echo "Killing existing substrate pid $pid..."
      docker exec "$SUBSTRATE_CONTAINER_NAME" kill -9 "$pid"
    done
  fi
  if [[ $RESTART_CHAIN == true ]]; then
    docker exec -d "$SUBSTRATE_CONTAINER_NAME" rm -rf ./chain-data
  fi
fi

# switch db
if [[ $TEST_DB == true ]]; then
  # if [[ -n "$SUBSTRATE_PID" ]]; then
  #   echo "Killing existing substrate..."
  #   docker exec "$SUBSTRATE_CONTAINER_NAME" kill -9 "${SUBSTRATE_PID//$'\n'/ }"
  # fi
  docker exec -d "$SUBSTRATE_CONTAINER_NAME" rm -rf ./chain-test
  docker cp ./.chain-test/. "$SUBSTRATE_CONTAINER_NAME":/chain-test
  docker exec -d "$SUBSTRATE_CONTAINER_NAME" bash -c "substrate-contracts-node --dev -d ./chain-test --unsafe-ws-external --rpc-external --prometheus-external -lerror,runtime::contracts=debug >> /proc/$MAIN_PID/fd/1  2>&1"
else

  docker exec -d "$SUBSTRATE_CONTAINER_NAME" bash -c "substrate-contracts-node --dev -d ./chain-data --unsafe-ws-external --rpc-external --prometheus-external -lerror,runtime::contracts=debug >> /proc/$MAIN_PID/fd/1  2>&1"
fi

# Mac OSX cannot curl docker container https://stackoverflow.com/a/45390994/1178971
if [[ "$OSTYPE" == "darwin"* ]]; then
  SUBSTRATE_CONTAINER_IP="0.0.0.0"
else
  SUBSTRATE_CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$SUBSTRATE_CONTAINER_NAME")
fi

rpc_methods () {
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
