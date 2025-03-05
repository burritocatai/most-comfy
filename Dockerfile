FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel

LABEL org.opencontainers.image.authors="danwiseman"
LABEL org.opencontainers.image.base.name="https://hub.docker.com/pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel"
LABEL org.opencontainers.image.source="https://github.com/burritocatai/most-comfy"
LABEL org.opencontainers.image.description="A Dockerfile for building a container with PyTorch, CUDA, and Rust for the Most Comfy Notebook on Brev."


WORKDIR /

RUN rm /bin/sh && ln -s /bin/bash /bin/sh


# Install dependencies needed for Rust
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    git \
    gcc \
    pkg-config \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install Rust using rustup (default installation)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Add Rust to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Verify installation
RUN rustc --version && cargo --version

