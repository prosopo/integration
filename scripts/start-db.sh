#!/bin/zsh
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--test-db]

    Options:
        --test-db:                load a fresh test db
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

# startup the db container
docker compose up provider-db -d
DB_CONTAINER_NAME=$(docker ps -q -f name=provider-db)

# load a fresh test db
if [[ $TEST_DB == true ]]; then
  # drop the db
  docker exec --env-file .env.test "$DB_CONTAINER_NAME" bash -c 'echo "Dropping $MONGO_INITDB_DATABASE" && mongo $MONGO_INITDB_DATABASE -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "db.dropDatabase()"'
  # copy the test db to the container
  docker cp ./.db-test/. "$DB_CONTAINER_NAME":/db-test
  if [ -f ./.db-test/prosopo_dataset.json ]; then
    docker exec -it --env-file .env.test "$DB_CONTAINER_NAME" bash -c 'mongoimport -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --db $MONGO_INITDB_DATABASE --collection dataset --file /db-backup-test/prosopo_dataset.json'
  fi
  if [ -f ./.db-test/prosopo_captchas.json ]; then
    docker exec -it --env-file .env.test "$DB_CONTAINER_NAME" bash -c 'mongoimport -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --db $MONGO_INITDB_DATABASE --collection captchas --file /db-backup-test/prosopo_captchas.json'
  fi
fi
