FROM node:16-alpine AS dev
RUN apk add git clang curl libressl-dev llvm eudev-dev cmake ninja && \
    apk add --update --no-cache python3 gcc g++ libc-dev make && ln -sf python3 /usr/bin/python && \
    git clone https://github.com/WebAssembly/binaryen /home/root/binaryen && \
    cd /home/root/binaryen && git fetch --all --tags && git checkout tags/version_105 && \
    cd /home/root/binaryen && cmake . -G Ninja -DCMAKE_CXX_FLAGS="-static" -DCMAKE_C_FLAGS="-static" -DCMAKE_BUILD_TYPE=Release -DBUILD_STATIC_LIB=ON -DCMAKE_INSTALL_PREFIX=install && \
    cd /home/root/binaryen && ninja install && \
    cp /home/root/binaryen/install/bin/* /usr/bin && cp /home/root/binaryen/install/include/* /usr/include && cp /home/root/binaryen/install/lib/* /usr/lib && \
    rm -rf /home/root/binaryen && \
    apk add curl zsh && \
    apk autoremove -y && \
    apk purge -y --auto-remove
USER root
ENV USER=node
RUN mkdir -p /usr/src && chown -R $USER:$USER /usr/src
USER $USER
WORKDIR /usr/src
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN . ~/.cargo/env && \
    rustup default stable &&\
    rustup update &&\
    rustup update nightly &&\
    rustup target add wasm32-unknown-unknown --toolchain nightly && \
    rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-musl && \
    cargo install cargo-dylint dylint-link
RUN . ~/.cargo/env && cargo install cargo-contract --vers ^0.17 --force
RUN yarn set version stable && yarn plugin import workspace-tools
ENTRYPOINT ["tail", "-f", "/dev/null"]
