./scripts/run-dev.sh --restart-chain --deploy-protocol --deploy-dapp
SUBSTRATE_CONTAINER_NAME=$(docker ps -q -f name=substrate-node)
PROTOCOL_COMMIT=$(git rev-parse HEAD:protocol --short HEAD:protocol | tail -n 1)
docker commit "$SUBSTRATE_CONTAINER_NAME" prosopo/substrate:test-$PROTOCOL_COMMIT

# https://stackoverflow.com/questions/2320564/sed-i-command-for-in-place-editing-to-work-with-both-gnu-sed-and-bsd-osx/38595160#38595160
sedi() {
  sed --version >/dev/null 2>&1 && sed -i "$@" || sed -i "" "$@"
}

# Put the new contract addresses in the env.test.txt template file
ENV_FILE=env.test.txt
PROTOCOL_CONTRACT_ADDRESS=$(echo "$(<.env.protocol)" | cut -d '=' -f2)
DAPP_CONTRACT_ADDRESS=$(echo "$(<.env.dapp)" | cut -d '=' -f2)
# CONTRACT_ADDRESS
grep -q "^CONTRACT_ADDRESS=.*" "$ENV_FILE" && sedi -e "s/^CONTRACT_ADDRESS=.*/CONTRACT_ADDRESS=$PROTOCOL_CONTRACT_ADDRESS/g" "$ENV_FILE"
# DAPP_CONTRACT_ADDRESS
grep -q "^DAPP_CONTRACT_ADDRESS=.*" "$ENV_FILE" && sedi -e "s/^DAPP_CONTRACT_ADDRESS=.*/DAPP_CONTRACT_ADDRESS=$DAPP_CONTRACT_ADDRESS/g" "$ENV_FILE"
