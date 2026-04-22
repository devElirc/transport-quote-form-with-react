FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN mkdir -p /app /tests /logs/verifier
