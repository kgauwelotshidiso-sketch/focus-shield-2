FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    git-lfs \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME} \
    && flutter config --no-analytics \
    && flutter precache --android \
    && dart --disable-analytics

WORKDIR /workspaces/focus-shield-2
