FROM paritytech/contracts-ci-linux:latest

WORKDIR /usr/src

COPY ./protocol ./protocol

ENV CONTRACT_NAME protocol
ENV CONTRACT_PATH "/usr/src/protocol/contracts"
ENV CONTRACT_ARGS "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY 2000000000000"
# - CONTRACT_ARGS= # dapp
ENV SUBSTRATE_URL "ws://substrate-node:9944"
ENV SURI "//Alice"
ENV ENDOWMENT 1000000000000
ENV CONSTRUCTOR new

# RUN cat /usr/src/protocol/contracts/Cargo.toml
# RUN exit 1

WORKDIR /usr/src/protocol/crates/storage/derive

RUN cargo metadata --format-version 1 --manifest-path "Cargo.toml"

WORKDIR /usr/src/protocol

# RUN cargo metadata --format-version 1 --manifest-path=Cargo.toml

RUN cargo contract instantiate "./contracts/target/ink/prosopo.wasm" --args "$CONTRACT_ARGS" --constructor "$CONSTRUCTOR" --suri "$SURI" --value "$ENDOWMENT" --url "$SUBSTRATE_URL" --manifest-path "./contracts/Cargo.toml"
