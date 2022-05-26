FROM debian:bookworm-slim AS builder
RUN apt-get update && apt-get install -y \
    curl \
    git \
    openssl \
    pkg-config \
    python3 \
    zsh
RUN ln -sf python3 /usr/bin/python
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install nodejs -y
RUN corepack enable
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
WORKDIR /usr/src
ENTRYPOINT ["tail", "-f", "/dev/null"]
