FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    binaryen \
    clang \
    cmake \
    curl \
    g++ \
    gcc \
    git \
    libc-dev \
    libssl-dev \
    llvm \
    make \
    openssl \
    pkg-config \
    python3 \
    zsh
RUN ln -sf python3 /usr/bin/python

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install nodejs -y
RUN npm install --global yarn

WORKDIR /usr/src
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN . ~/.cargo/env && \
    rustup default stable &&\
    rustup update &&\
    rustup update nightly &&\
    rustup target add wasm32-unknown-unknown --toolchain nightly && \
    rustup component add rust-src --toolchain nightly && \
    cargo install cargo-dylint dylint-link
RUN . ~/.cargo/env && cargo install cargo-contract --vers ^0.17 --force
ENTRYPOINT ["tail", "-f", "/dev/null"]
