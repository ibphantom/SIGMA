# Root Dockerfile
FROM rust:1.70-alpine AS backend-builder
WORKDIR /app
COPY backend/Cargo.toml backend/Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

COPY backend/src ./src
RUN cargo build --release

FROM alpine:latest
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=backend-builder /app/target/release/sigma-backend /app/
EXPOSE 8080
CMD ["./sigma-backend"]
