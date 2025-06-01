FROM rust:1.78-slim as builder

RUN apt-get update && apt-get install -y musl-tools pkg-config libssl-dev
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src ./src

ENV RUSTFLAGS='-C target-feature=-crt-static'
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt
ENTRYPOINT ["/usr/local/bin/komeo-mqtt"]
