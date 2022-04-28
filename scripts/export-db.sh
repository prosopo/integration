#!/bin/zsh

DB_CONTAINER_NAME=$(docker ps -q -f name=provider-db)
echo "DB Container ID $DB_CONTAINER_NAME"
rm -rf ./.db-test
echo "DB Name $DATABASE_NAME"
echo "Test DB $TEST_DB"


docker exec -it -u "$MONGO_INITDB_ROOT_USERNAME" "$DB_CONTAINER_NAME" bash -c "mongoexport --db $DATABASE_NAME -c dataset -u root -p root --authenticationDatabase admin --out /db-test/prosopo_dataset.json"
docker exec -it -u "$MONGO_INITDB_ROOT_USERNAME" "$DB_CONTAINER_NAME" bash -c "mongoexport --db $DATABASE_NAME -c captchas -u root -p root --authenticationDatabase admin --out /db-test/prosopo_captchas.json"
docker cp $DB_CONTAINER_NAME:/db-test/. ./.db-test
