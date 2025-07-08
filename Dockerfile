# Stage 1: Build Frontend (Elm)
FROM node:18-alpine AS frontend-builder
WORKDIR /frontend

# Install Elm compiler
RUN npm install -g elm@0.19.1

# Copy Elm project files
COPY frontend/elm.json ./
COPY frontend/src ./src

# Build Elm frontend
RUN mkdir -p dist \
    && elm make src/Main.elm --optimize --output=dist/elm.js

# Stage 2: Build Backend (Rust)
FROM rust:1.70-slim-buster AS backend-builder
WORKDIR /backend

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config libssl-dev clang cmake build-essential curl gnupg git \
    && rm -rf /var/lib/apt/lists/*

# Copy Rust source
COPY backend/Cargo.toml backend/Cargo.lock ./
COPY backend/src ./src

# Compile the Rust backend
RUN cargo build --release

# Stage 3: Final image
FROM debian:bullseye-slim AS final
WORKDIR /app

# Runtime dependencies
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy Rust binary from builder
COPY --from=backend-builder /backend/target/release/sigma-backend ./

# Copy built frontend
COPY --from=frontend-builder /frontend/dist ./dist

# Ensure persistent volume structure and link compatibility
RUN mkdir -p /app/data/gnupg/keys \
    && ln -s /app/data /data

EXPOSE 34998
CMD ["./sigma-backend"]
