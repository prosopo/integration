FROM paritytech/contracts-ci-linux:latest
WORKDIR /usr/src/$CONTRACT_NAME
#RUN cargo contract instantiate "/usr/src/$CONTRACT_NAME/contracts/target/ink/$CONTRACT_NAME.wasm" --args $CONTRACT_ARGS --constructor "$CONSTRUCTOR" --suri "$SURI" --value "$ENDOWMENT" --url "$SUBSTRATE_URL"
