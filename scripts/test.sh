./scripts/start-substrate.sh --test-db --restart-chain
./scripts/start-db.sh --env-file=.env.test
CONTAINER_NAME=$(docker ps -q -f name=provider-api)
docker cp .database_accounts.json $CONTAINER_NAME:/usr/src/database_accounts.json
docker exec -ti $CONTAINER_NAME sh -c "yarn workspace @prosopo/provider run test:mock"
./scripts/start-substrate.sh
./scripts/start-db.sh