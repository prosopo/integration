#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--test-db]

    Options:
        --test-db:      use test db
USAGE
  exit 1
}

TEST_DB=false

for arg in "$@"; do
  case $arg in
  --test-db)
    TEST_DB=true
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
if [ -n "$SUBSTRATE_PID" ]; then
  echo "Killing existing substrate..."
  docker exec $SUBSTRATE_CONTAINER_NAME kill -9 $SUBSTRATE_PID
fi

# switch db
if [[ $TEST_DB == true ]]; then
  docker exec -d $SUBSTRATE_CONTAINER_NAME rm -rf ./chain-test
  docker cp ./.chain-test/. $SUBSTRATE_CONTAINER_NAME:/chain-test
  docker exec -d $SUBSTRATE_CONTAINER_NAME substrate-contracts-node --dev -d ./chain-test --unsafe-ws-external --rpc-external --prometheus-external -linfo,runtime::contracts=debug
else
  docker exec -d $SUBSTRATE_CONTAINER_NAME substrate-contracts-node --dev -d ./chain-data --unsafe-ws-external --rpc-external --prometheus-external -linfo,runtime::contracts=debug
fi


# Mac OSX cannot curl docker container https://stackoverflow.com/a/45390994/1178971
if [[ "$OSTYPE" == "darwin"* ]]; then
  SUBSTRATE_CONTAINER_IP="0.0.0.0"
else
  SUBSTRATE_CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$SUBSTRATE_CONTAINER_NAME")
fi
RESPONSE_CODE=$(curl -sI -o /dev/null -w "%{http_code}\n" "$SUBSTRATE_CONTAINER_IP":9944)
while [ "$RESPONSE_CODE" != '400' ]; do
  RESPONSE_CODE=$(curl -sI -o /dev/null -w "%{http_code}\n" "$SUBSTRATE_CONTAINER_IP":9944)
  sleep 1
done
