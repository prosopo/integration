FROM debian:bookworm-slim

RUN apt update
RUN apt install -y git clang curl libssl-dev llvm libudev-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN . ~/.cargo/env && \
    rustup default stable &&\
    rustup update &&\
    rustup update nightly &&\
    rustup target add wasm32-unknown-unknown --toolchain nightly

RUN . ~/.cargo/env && \
    git clone https://github.com/paritytech/substrate-contracts-node && \
    cd substrate-contracts-node && \
    git checkout 19395a8e00d87328ecfe5a424fee6b19e379daec && \
    cargo build && \
    ./target/debug/substrate-contracts-node --dev --tmp --version

EXPOSE 9615
EXPOSE 9944

CMD [ "./substrate-contracts-node/target/debug/substrate-contracts-node", \
        "--unsafe-ws-external", \
        "--prometheus-external", \
        "--dev", \
        "--tmp", \
        "-lerror,runtime::contracts=debug"
    ]
