#!/bin/zsh
# flags
function usage() {
  cat <<USAGE

    Usage: $0 [--env-file #0]

    Options:
        --env-file:                path to an env file
USAGE
  exit 1
}

TEST_DB=false
ENV_FILE=.env

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
  -h | --help)
    usage # run usage function on help
    ;;
  *)
    usage # run usage function if wrong argument provided
    ;;
  esac
done

# startup the db container
echo "Starting db..."
docker compose --env-file "$ENV_FILE" up provider-db -d
DB_CONTAINER_NAME=$(docker ps -q -f name=provider-db)

# load a fresh test db
if [[ $TEST_DB == true ]]; then
  # drop the test db
  docker exec --env-file $ENV_FILE "$DB_CONTAINER_NAME" bash -c 'echo "Dropping $MONGO_INITDB_DATABASE" && mongo $MONGO_INITDB_DATABASE -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "db.dropDatabase()"'
  # copy the test db to the container
  docker cp ./.db-test/. "$DB_CONTAINER_NAME":/db-test
  if [ -f ./.db-test/prosopo_dataset.json ]; then
    docker exec -it --env-file $ENV_FILE "$DB_CONTAINER_NAME" bash -c 'mongoimport -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --db $MONGO_INITDB_DATABASE --collection dataset --file /db-test/prosopo_dataset.json'
  fi
  if [ -f ./.db-test/prosopo_captchas.json ]; then
    docker exec -it --env-file $ENV_FILE "$DB_CONTAINER_NAME" bash -c 'mongoimport -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --db $MONGO_INITDB_DATABASE --collection captchas --file /db-test/prosopo_captchas.json'
  fi
fi
