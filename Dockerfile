# Build Frontend
FROM node:18-alpine AS frontend-builder
WORKDIR /frontend
RUN npm install -g elm@0.19.1
COPY frontend/elm.json frontend/src/ ./ 
RUN mkdir -p dist && elm make src/Main.elm --optimize --output=dist/elm.js

# Build Backend
FROM rust:1.70-slim-buster AS backend-builder
WORKDIR /backend
COPY backend/ ./
RUN cargo build --release

# Final Image
FROM debian:bullseye-slim
WORKDIR /app

# Copy Backend Binary
COPY --from=backend-builder /backend/target/release/sigma-backend ./sigma-backend

# Copy Frontend Files
COPY --from=frontend-builder /frontend/dist ./frontend

# Copy public assets and configuration
COPY backend/static ./static

# Environment and ports
ENV RUST_LOG=info
ENV SIGMA_FRONTEND_PORT=34999
ENV SIGMA_BACKEND_PORT=34998
EXPOSE 34998
EXPOSE 34999

CMD ["./sigma-backend"]
