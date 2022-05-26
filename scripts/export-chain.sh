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

SUBSTRATE_CONTAINER_NAME=$(docker ps -q -f name=substrate-node)
rm -rf ./.chain-test

if [[ $TEST_DB == true ]]; then
  docker cp $SUBSTRATE_CONTAINER_NAME:/chain-test/. ./.chain-test
else 
  sedi () {
      sed --version >/dev/null 2>&1 && sed -i "$@" || sed -i "" "$@"
  }
  cp .env .env.test
  sedi -e "s/=prosopo/=prosopo_test/g" .env.test
  docker cp $SUBSTRATE_CONTAINER_NAME:/chain-data/. ./.chain-test
fi
