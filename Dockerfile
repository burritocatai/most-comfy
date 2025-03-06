FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04

LABEL org.opencontainers.image.authors="danwiseman"
LABEL org.opencontainers.image.base.name="https://hub.docker.com/pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel"
LABEL org.opencontainers.image.source="https://github.com/burritocatai/bref-comfyui"
LABEL org.opencontainers.image.description="A Dockerfile for building a container to run ComfyUI with Auto Nodes and Models download"


WORKDIR /

RUN rm /bin/sh && ln -s /bin/bash /bin/sh


# Install dependencies needed for Rust
RUN apt-get update && apt-get install -y \
    git python3 python3.10-venv python3-dev python3-pip \
    curl \
    build-essential \
    git \
    gcc \
    pkg-config \
    libxml2-dev libxslt1-dev zlib1g-dev libgl1 \
    libgl1-mesa-glx \
    libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Install Rust using rustup (default installation)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Add Rust to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Verify installation
RUN rustc --version && cargo --version

# Get ready for Comfyui
RUN useradd comfyui && \
    mkdir /home/comfyui && \
    mkdir /home/comfyui/.cache && \
    mkdir /comfyui && \
    mkdir /comfyui/cache

COPY ./shell/start.sh /comfyui/start.sh

RUN chown -R comfyui:comfyui /comfyui && \
    chown -R comfyui:comfyui /home/comfyui && \
    chmod +x /comfyui/start.sh

USER comfyui

WORKDIR /comfyui


ENTRYPOINT ["/bin/bash", "/comfyui/start.sh"]