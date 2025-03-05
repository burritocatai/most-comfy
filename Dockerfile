FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel

LABEL org.opencontainers.image.authors="danwiseman"
LABEL org.opencontainers.image.base.name="https://hub.docker.com/pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel"
LABEL org.opencontainers.image.source="https://github.com/burritocatai/bref-comfyui"


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