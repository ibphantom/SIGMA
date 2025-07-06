# Stage 1: Build Elm frontend
FROM node:18-alpine AS frontend-builder

WORKDIR /frontend
RUN npm install -g elm@0.19.1
COPY frontend/elm.json frontend/src/ ./
RUN mkdir -p dist && elm make src/Main.elm --optimize --output=dist/elm.js

# Stage 2: Build Rust backend
FROM rust:1.70-slim-buster AS backend-builder

WORKDIR /backend
COPY backend/ ./
RUN cargo build --release

# Stage 3: Final image
FROM debian:bullseye-slim

WORKDIR /app
COPY --from=backend-builder /backend/target/release/sigma-backend ./sigma-backend
COPY --from=frontend-builder /frontend/dist ./frontend
RUN mkdir -p ./static && echo "placeholder" > ./static/.keep

ENV SIGMA_BACKEND_PORT=34998
EXPOSE 34998
CMD ["./sigma-backend"]
