FROM debian:bookworm-slim AS builder

RUN apt-get update
RUN apt-get install -y \
    build-essential \
    clang \
    curl \
    git \
    libssl-dev \
    libudev-dev \
    llvm \
    pkg-config

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN . ~/.cargo/env && \
    rustup default stable &&\
    rustup update &&\
    rustup update nightly &&\
    rustup target add wasm32-unknown-unknown --toolchain nightly

RUN git clone -b 'monthly-2022-03' --depth 1 https://github.com/paritytech/substrate

WORKDIR /substrate

RUN . ~/.cargo/env && \
    cargo build --verbose --locked --release


FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get upgrade -y --only-upgrade libstdc++6


COPY --from=builder /substrate/target/release/substrate /usr/local/bin
COPY --from=builder /substrate/target/release/subkey /usr/local/bin
COPY --from=builder /substrate/target/release/node-template /usr/local/bin
COPY --from=builder /substrate/target/release/chain-spec-builder /usr/local/bin

EXPOSE 30333 9933 9944 9615

USER root
#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT [ "substrate", \
    "--dev", \
    "--tmp", \
    "--unsafe-ws-external", \
    "--rpc-external", \
    "--prometheus-external", \
    "-lerror,runtime::contracts=debug" \
    ]
