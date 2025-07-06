FROM rust:1.77-alpine as builder

RUN apk add --no-cache musl-dev openssl-dev pkgconfig

WORKDIR /usr/src/app

COPY Cargo.toml .
COPY src ./src

RUN cargo build --release

FROM alpine:latest

RUN apk add --no-cache openssl

WORKDIR /root/

COPY --from=builder /usr/src/app/target/release/sigma-backend ./

EXPOSE 8000

CMD ["./sigma-backend"]
