### Stage 1 - Build Frontend (Elm)
FROM node:18-alpine AS frontend-builder
WORKDIR /frontend

RUN npm install -g elm@0.19.1

COPY frontend/elm.json ./
COPY frontend/src ./src

# Avoid interactive prompts and ensure build breaks on error
RUN mkdir -p dist \
  && elm make src/Main.elm --optimize --output=dist/elm.js --yes


### Stage 2 - Build Backend (Rust)
FROM rust:1.70-slim-buster AS backend-builder
WORKDIR /backend

RUN apt-get update && apt-get install -y \
    pkg-config libssl-dev clang cmake build-essential curl gnupg git \
 && rm -rf /var/lib/apt/lists/*

COPY backend/Cargo.toml backend/Cargo.lock ./
COPY backend/src ./src

# Optional: speeds up builds using minimal incremental compilation caching
RUN mkdir -p .cargo \
 && echo '[build]\ntarget-dir = "/build"' > .cargo/config.toml

RUN cargo build --release


### Stage 3 - Final Runtime Image
FROM debian:bullseye-slim AS final

RUN apt-get update && apt-get install -y \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=backend-builder /build/release/sigma-backend ./
COPY --from=frontend-builder /frontend/dist ./dist

EXPOSE 34998

CMD ["./sigma-backend"]
