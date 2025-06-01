# Use a recent Rust image with Cargo 1.73+ (compatible with lock file v4)
FROM rust:1.87 as builder

# Install cmake, musl-tools, pkg-config, and openssl dependencies for static compilation
RUN apt-get update && apt-get install -y cmake musl-tools pkg-config libssl-dev

# Add musl target based on build argument
ARG TARGET
RUN rustup target add $TARGET

WORKDIR /app

COPY . .

# Build release binary for the specified target
RUN cargo build --release --target $TARGET

FROM alpine:3.20

# Install CA certificates for TLS
RUN apk add --no-cache ca-certificates

# Copy the built binary according to the target
ARG TARGET
RUN if [ "$TARGET" = "x86_64-unknown-linux-musl" ]; then \
      cp /app/target/x86_64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt; \
    elif [ "$TARGET" = "aarch64-unknown-linux-musl" ]; then \
      cp /app/target/aarch64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt; \
    else \
      echo "Unsupported TARGET $TARGET" && exit 1; \
    fi

ENTRYPOINT ["/usr/local/bin/komeo-mqtt"]
