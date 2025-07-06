# ====== Stage 1: Build Elm Frontend ======
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
RUN npm install -g elm@0.19.1
COPY frontend/elm.json frontend/src/ ./
RUN mkdir -p dist && elm make src/Main.elm --optimize --output=dist/elm.js
COPY frontend/dist ./dist

# ====== Stage 2: Build Rust Backend ======
FROM rust:1.77 as backend-builder
WORKDIR /app/backend
COPY backend ./backend
RUN apt-get update && apt-get install -y clang pkg-config libssl-dev
RUN cargo build --release

# ====== Stage 3: Final Container ======
FROM alpine:3.18
RUN apk add --no-cache openssl
WORKDIR /app
COPY --from=frontend-builder /app/frontend/dist ./frontend
COPY --from=backend-builder /app/backend/target/release/backend ./backend
COPY template.xml ./template.xml
COPY .env.example .env
EXPOSE 34998
CMD ["./backend"]
