FROM rust:1.76-alpine AS builder

RUN apk add --no-cache musl-dev openssl-dev pkgconfig git

WORKDIR /app

# Cache dependencies
COPY backend/Cargo.toml backend/Cargo.lock ./
COPY backend/src ./src
RUN cargo build --release

# Runtime image
FROM alpine:latest

RUN apk add --no-cache ca-certificates

WORKDIR /app
COPY --from=builder /app/target/release/sigma-backend .

ENV RUST_LOG=info

CMD ["./sigma-backend"]
