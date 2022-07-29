FROM paritytech/contracts-ci-linux:latest

WORKDIR /usr/src

COPY ./protocol ./protocol

ENV CONTRACT_NAME protocol
ENV CONTRACT_PATH "./protocol/contracts"
ENV CONTRACT_ARGS "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY 2000000000000"
# - CONTRACT_ARGS= # dapp
ENV SUBSTRATE_URL "ws://substrate-node:9944"
ENV SURI "//Alice"
ENV ENDOWMENT 1000000000000
ENV CONSTRUCTOR new

# RUN cat /usr/src/protocol/contracts/Cargo.toml
# RUN exit 1

# WORKDIR /usr/src/protocol/contracts

RUN cargo metadata --format-version 1 --manifest-path "/usr/src/protocol/contracts/Cargo.toml"

# WORKDIR /usr/src

RUN cargo contract instantiate "$CONTRACT_PATH/target/ink/prosopo.wasm" --args "$CONTRACT_ARGS" --constructor "$CONSTRUCTOR" --suri "$SURI" --value "$ENDOWMENT" --url "$SUBSTRATE_URL"
