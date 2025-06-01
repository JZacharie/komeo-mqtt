# Use a recent Rust image with Cargo 1.73+ (compatible with lock file v4)
FROM rust:1.73 as builder

# Install cmake, musl-tools, and other dependencies for static compilation
RUN apt-get update && apt-get install -y cmake musl-tools pkg-config libssl-dev

# Add the musl target for static linking
RUN rustup target add x86_64-unknown-linux-musl

# Set working directory inside the container
WORKDIR /app

# Copy source code into the container
COPY . .

# Build release for musl target to get a static binary
RUN cargo build --release --target x86_64-unknown-linux-musl

# Final stage: lightweight alpine image
FROM alpine:3.20

# Install CA certificates (needed for HTTPS if used, e.g. MQTT TLS)
RUN apk add --no-cache ca-certificates

# Copy the built binary from the builder stage
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt

# Set the binary as the entrypoint
ENTRYPOINT ["/usr/local/bin/komeo-mqtt"]
