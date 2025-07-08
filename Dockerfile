# Stage 1: Build Frontend (Elm)
FROM node:18-alpine AS frontend-builder
WORKDIR /frontend

RUN npm install -g elm@0.19.1

COPY frontend/elm.json ./
COPY frontend/src ./src

RUN mkdir -p dist \
    && elm make src/Main.elm --optimize --output=dist/elm.js

# Stage 2: Build Backend (Rust)
FROM rust:1.70-slim-buster AS backend-builder
WORKDIR /backend

RUN apt-get update && apt-get install -y \
    pkg-config libssl-dev clang cmake build-essential curl gnupg git \
    && rm -rf /var/lib/apt/lists/*

COPY backend/Cargo.toml backend/Cargo.lock ./
COPY backend/src ./src

RUN cargo build --release

# Stage 3: Final Runtime Image
FROM debian:bullseye-slim AS final
WORKDIR /app

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=backend-builder /backend/target/release/sigma-backend ./
COPY --from=frontend-builder /frontend/dist ./dist

RUN mkdir -p /app/data/gnupg/keys && ln -s /app/data /data

EXPOSE 34998
CMD ["./sigma-backend"]
