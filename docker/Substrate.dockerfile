FROM debian:bookworm-slim AS base

RUN apt update && \
    apt install build-essential -y && \
    apt install -y git clang curl libssl-dev llvm libudev-dev && \
    apt install -y pkg-config libssl-dev && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . ~/.cargo/env && \
    rustup default stable && \
    rustup update && \
    rustup update nightly && \
    rustup target add wasm32-unknown-unknown --toolchain nightly && \
    apt autoremove -y && \
    apt purge -y --auto-remove

RUN . ~/.cargo/env && \
    git clone https://github.com/paritytech/substrate

RUN . ~/.cargo/env && \
    cd substrate && \
    cargo build --locked --release

EXPOSE 9615
EXPOSE 9944
EXPOSE 9933

WORKDIR "substrate"

RUN stat ./target/release/

#ENTRYPOINT ["tail", "-f", "/dev/null"]
COPY ./Substrate.dockerfile.boot.sh /home/root/boot.sh
USER root
RUN chmod +x /home/root/boot.sh
CMD /home/root/boot.sh
