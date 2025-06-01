# Use a recent Rust image with Cargo 1.73+ (compatible with Cargo.lock version 4)
FROM rust:1.87 as builder

# Install build dependencies for static compilation: cmake, musl-tools, pkg-config, libssl-dev
RUN apt-get update && apt-get install -y cmake musl-tools pkg-config libssl-dev

# Add musl targets for static linking on amd64 and arm64 architectures
RUN rustup target add x86_64-unknown-linux-musl aarch64-unknown-linux-musl

# Set the working directory inside the container
WORKDIR /app

# Copy the entire source code into the container
COPY . .

# Build the project in release mode for x86_64 (amd64) musl target
RUN cargo build --release --target x86_64-unknown-linux-musl

# Build the project in release mode for aarch64 (arm64) musl target
RUN cargo build --release --target aarch64-unknown-linux-musl

# Start a minimal Alpine Linux image for the final image
FROM alpine:3.20

# Install CA certificates (necessary for HTTPS/TLS support, e.g., MQTT over TLS)
RUN apk add --no-cache ca-certificates

# Copy the compiled binary for amd64 architecture from the builder stage
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt-amd64

# Copy the compiled binary for arm64 architecture from the builder stage
COPY --from=builder /app/target/aarch64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt-arm64

# Default entrypoint uses the amd64 binary
# When used in a multi-arch manifest, Docker will automatically select the appropriate binary for the platform
ENTRYPOINT ["/usr/local/bin/komeo-mqtt-amd64"]
