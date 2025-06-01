# Stage 1: Builder
FROM rust:1.87 as builder

# Install system dependencies for building musl targets
RUN apt-get update && apt-get install -y cmake musl-tools pkg-config libssl-dev

# Add musl targets (x86_64 and aarch64)
RUN rustup target add x86_64-unknown-linux-musl aarch64-unknown-linux-musl

WORKDIR /app

# Copy source code
COPY . .

# Build both targets (cross-compilation)
RUN cargo build --release --target x86_64-unknown-linux-musl
RUN cargo build --release --target aarch64-unknown-linux-musl

# Stage 2: Final minimal image
FROM alpine:3.20

RUN apk add --no-cache ca-certificates

ARG TARGET
# Copy the binary corresponding to TARGET to final image
RUN if [ "$TARGET" = "x86_64-unknown-linux-musl" ]; then \
      cp /app/target/x86_64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt; \
    elif [ "$TARGET" = "aarch64-unknown-linux-musl" ]; then \
      cp /app/target/aarch64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt; \
    else \
      echo "Unsupported TARGET $TARGET" && exit 1; \
    fi

ENTRYPOINT ["/usr/local/bin/komeo-mqtt"]
