FROM paritytech/contracts-ci-linux:production

WORKDIR /usr/src

COPY protocol protocol/

ENV CONTRACT_NAME protocol
ENV CONTRACT_PATH "protocol/contracts"
ENV CONTRACT_ARGS "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY 2000000000000"
# - CONTRACT_ARGS= # dapp
ENV SUBSTRATE_URL "ws://localhost:9944"
ENV SURI "//Alice"
ENV ENDOWMENT 1000000000000
ENV CONSTRUCTOR "default"

# RUN cat /usr/src/protocol/contracts/Cargo.toml
# RUN exit 1

# WORKDIR /usr/src/protocol/contracts

# RUN echo $(ls -l /usr/src/protocol/contracts)

# WORKDIR /usr/src/protocol/contracts

# RUN cargo metadata --manifest-path "Cargo.toml"

# WORKDIR /usr/src

# RUN cargo metadata --format-version 1 --manifest-path=Cargo.toml

WORKDIR /usr/src/protocol/contracts

RUN cargo contract instantiate "./target/ink/prosopo.wasm" --args "$CONTRACT_ARGS" --constructor "$CONSTRUCTOR" --suri "$SURI" --value "$ENDOWMENT" --url "$SUBSTRATE_URL" --manifest-path "./Cargo.toml"
