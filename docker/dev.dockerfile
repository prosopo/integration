FROM rust:latest
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
    musl-tools \
    musl-dev \
    openssl \
    pkg-config \
    python3 \
    zsh
RUN ln -sf python3 /usr/bin/python
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install nodejs -y
RUN corepack enable
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN rustup default stable && \
    rustup update && \
    rustup update nightly && \
    rustup target add wasm32-unknown-unknown --toolchain nightly && \
    rustup component add rust-src --toolchain nightly && \
    cargo install cargo-dylint dylint-link && \
    cargo install cargo-contract --vers ^1.2.0 --force && \
    cargo install cargo-tarpaulin
WORKDIR /usr/src
ENTRYPOINT ["tail", "-f", "/dev/null"]
