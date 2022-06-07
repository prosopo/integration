./scripts/run-dev.sh --restart-chain --deploy-protocol --deploy-dapp
SUBSTRATE_CONTAINER_NAME=$(docker ps -q -f name=substrate-node)
PROTOCOL_COMMIT=$(git rev-parse HEAD:protocol --short HEAD:protocol | tail -n 1)
docker commit "$SUBSTRATE_CONTAINER_NAME" prosopo/substrate:test-$PROTOCOL_COMMIT
