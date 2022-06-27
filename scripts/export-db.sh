#!/bin/bash
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--env-file #0]

    Options:
        --env-file:                path to an env file
USAGE
  exit 1
}

ENV_FILE=.env

for arg in "$@"; do
  case $1 in
  "")
    ;;
  --env-file)
    ENV_FILE=$2
    shift # Remove --install from `$@`
    ;;
  -h | --help)
    usage # run usage function on help
    ;;
  *)
    usage # run usage function if wrong argument provided
    ;;
  esac
  shift
done

DB_CONTAINER_NAME=$(docker ps -q -f name=provider-db)
echo "DB Container ID $DB_CONTAINER_NAME"
rm -rf ./.db-test
echo "ENV FILE $ENV_FILE"

docker exec --env-file $ENV_FILE -it -u "$MONGO_INITDB_ROOT_USERNAME" "$DB_CONTAINER_NAME" bash -c 'mongoexport --db $DATABASE_NAME -c dataset -u root -p root --authenticationDatabase admin --out /db-test/prosopo_dataset.json'
docker exec --env-file $ENV_FILE -it -u "$MONGO_INITDB_ROOT_USERNAME" "$DB_CONTAINER_NAME" bash -c 'mongoexport --db $DATABASE_NAME -c captchas -u root -p root --authenticationDatabase admin --out /db-test/prosopo_captchas.json'
docker cp $DB_CONTAINER_NAME:/db-test/. ./.db-test
