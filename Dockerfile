FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04


LABEL org.opencontainers.image.authors="danwiseman"
LABEL org.opencontainers.image.base.name="nvidia/cuda:12.4.0-runtime-ubuntu22.04"
LABEL org.opencontainers.image.source="https://github.com/burritocatai/most-comfy"
LABEL org.opencontainers.image.description="A Dockerfile for building a container with PyTorch, CUDA, and Rust for the Most Comfy Notebook on Brev."


WORKDIR /

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
    git python3 python3.10-venv python3-dev python3-pip \
    build-essential libssl-dev libffi-dev \
    libxml2-dev libxslt1-dev zlib1g-dev libgl1 \
    libgl1-mesa-glx \
    libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*


RUN pip3 install --upgrade pip && \
    pip3 install wheel && \
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install insightface onnxruntime onnxruntime-gpu huggingface_hub[cli]


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

WORKDIR /workspace
CMD ["/bin/bash"]