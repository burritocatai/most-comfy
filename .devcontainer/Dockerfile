FROM python:3.12.9-bookworm
USER root

RUN apt-get update && \
    apt-get -y install --reinstall ca-certificates && \
    apt-get -y install software-properties-common && \
    pip install --upgrade pip

RUN pip install ipykernel jupyter

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