#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--env-file #0]

    Options:
        --env-file:                path to an env file
        --populate:                populate database first
USAGE
  exit 1
}

TEST_DB=false
ENV_FILE=.env
POPULATE=false

for arg in "$@"; do
  case $arg in
  "")
    ;;
  --env-file=*)
    if [ ${arg#*=} = ".env.test" ]; then
      TEST_DB=true
    fi
    ENV_FILE=${arg#*=}
    ;;
  --populate)
    POPULATE=true
    ;;
  -h | --help)
    usage # run usage function on help
    ;;
  *)
    usage # run usage function if wrong argument provided
    ;;
  esac
done

# if [[ $POPULATE == true ]]; then
#   PROVIDER_CONTAINER_NAME=$(docker ps -q -f name=provider-api)
#   docker exec --env-file $ENV_FILE -it $PROVIDER_CONTAINER_NAME bash -c 'yarn populate-data'
# fi

if [[ $TEST_DB == true ]]; then
  ./scripts/export-chain.sh --test-db
else
  ./scripts/export-chain.sh
fi;
./scripts/export-db.sh --env-file $ENV_FILE
