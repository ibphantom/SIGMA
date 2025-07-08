### Stage 1 - Build Frontend (Elm)
FROM node:18-alpine AS frontend-builder
WORKDIR /frontend

# Install Elm
RUN npm install -g elm@0.19.1

# Copy Elm files
COPY frontend/elm.json ./
COPY frontend/src ./src

# Build Elm
RUN mkdir -p dist \
    && elm make src/Main.elm --optimize --output=dist/elm.js


### Stage 2 - Build Backend (Rust)
FROM rust:1.70-slim-buster AS backend-builder
WORKDIR /backend

# Install dependencies
RUN apt-get update && apt-get install -y \
    pkg-config libssl-dev clang cmake build-essential curl gnupg git && \
    rm -rf /var/lib/apt/lists/*

# Copy Rust files
COPY backend/Cargo.toml backend/Cargo.lock ./
COPY backend/src ./src

# Build
RUN cargo build --release


### Stage 3 - Final Runtime Image
FROM debian:bullseye-slim AS final
WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy backend binary
COPY --from=backend-builder /backend/target/release/sigma-backend ./

# Copy frontend output
COPY --from=frontend-builder /frontend/dist ./dist

# Expose port
EXPOSE 34998

CMD ["./sigma-backend"]
