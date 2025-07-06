FROM rust:1.70-alpine AS builder
RUN apk add --no-cache pkgconfig musl-dev clang openssl-dev

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src
RUN echo "// dummy" > src/lib.rs
RUN cargo build --release

COPY src ./src
RUN cargo build --release

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /app/target/release/backend ./backend
CMD ["./backend"]
EXPOSE 8000
