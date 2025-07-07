### Stage 1 - Build Frontend (Elm)
FROM node:18-alpine AS frontend-builder
WORKDIR /frontend

# Install Elm
RUN npm install -g elm@0.19.1

# Copy Elm project files
COPY frontend/elm.json ./
COPY frontend/src/ ./src/

# Build Elm frontend
RUN mkdir -p dist \
    && elm make src/Main.elm --optimize --output=dist/elm.js


### Stage 2 - Build Backend (Rust)
FROM rust:1.70-slim-buster AS backend-builder
WORKDIR /backend

# Install system dependencies
RUN apt-get update && apt-get install -y pkg-config libssl-dev clang cmake build-essential curl gnupg git

# Copy Rust source files and Cargo files
COPY backend/Cargo.toml ./
COPY backend/Cargo.lock ./
COPY backend/src/ ./src/

# Build the backend binary
RUN cargo build --release


### Stage 3 - Final Runtime Image
FROM debian:bullseye-slim AS final

# Install required runtime libraries
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy backend binary
COPY --from=backend-builder /backend/target/release/sigma-backend ./

# Copy frontend build output
COPY --from=frontend-builder /frontend/dist ./dist

# Expose backend port
EXPOSE 34998

# Start backend
CMD ["./sigma-backend"]
