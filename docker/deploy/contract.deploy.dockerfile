FROM paritytech/contracts-ci-linux:latest

RUN cargo contract instantiate "$CONTRACT_PATH/prosopo.wasm" --args $CONTRACT_ARGS --constructor "$CONSTRUCTOR" --suri "$SURI" --value "$ENDOWMENT" --url "$SUBSTRATE_URL" --verbose
