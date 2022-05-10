./scripts/start-substrate.sh --test-db
CONTAINER_NAME=$(docker ps -q -f name=provider-api)
docker exec -ti $CONTAINER_NAME sh -c "yarn workspace @prosopo/provider-core run test:mock"
./scripts/start-substrate.sh