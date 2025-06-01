# syntax=docker/dockerfile:experimental
ARG TARGET=x86_64-unknown-linux-musl

FROM rust:1.87 as builder

# Install dependencies for static build and cmake for native deps
RUN apt-get update && apt-get install -y cmake musl-tools pkg-config libssl-dev

# Add Rust target specified by build argument
RUN rustup target add ${TARGET}

WORKDIR /app

# Copy source code
COPY . .

# Build the release binary for the target
RUN cargo build --release --target ${TARGET}

# Final image: lightweight alpine
FROM alpine:3.20

# Install CA certificates if needed (ex: HTTPS, MQTT TLS)
RUN apk add --no-cache ca-certificates

# Copy the built binary from builder stage
COPY --from=builder /app/target/${TARGET}/release/komeo-mqtt /usr/local/bin/komeo-mqtt

ENTRYPOINT ["/usr/local/bin/komeo-mqtt"]
