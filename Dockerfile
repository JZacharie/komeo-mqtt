FROM rust:1.73 as builder

RUN apt-get update && apt-get install -y cmake musl-tools pkg-config libssl-dev

RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /app
COPY . .

RUN cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:3.20
RUN apk add --no-cache ca-certificates

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/komeo-mqtt /usr/local/bin/komeo-mqtt

ENTRYPOINT ["/usr/local/bin/komeo-mqtt"]
