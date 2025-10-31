# Stage 1: Builder
FROM rust:1.91 as builder

RUN apt-get update && apt-get install -y cmake musl-tools pkg-config libssl-dev

ARG TARGET
RUN rustup target add ${TARGET}

WORKDIR /app
COPY . .
RUN cargo build --release --target ${TARGET}

# Stage 2: Runtime
FROM alpine:3.22
RUN apk add --no-cache ca-certificates

ARG TARGET
COPY --from=builder /app/target/${TARGET}/release/komeo-mqtt /usr/local/bin/komeo-mqtt

ENTRYPOINT ["/usr/local/bin/komeo-mqtt"]
