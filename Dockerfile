FROM rust:1.72 AS backend-builder
WORKDIR /app
COPY ./backend ./backend
WORKDIR /app/backend
RUN apt-get update && apt-get install -y pkg-config libssl-dev && \
    cargo build --release

FROM node:18 AS elm-builder
WORKDIR /elm
COPY ./frontend ./frontend
WORKDIR /elm/frontend
RUN npm install -g elm && \
    elm make src/Main.elm --output=dist/elm.js

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y ca-certificates gnupg && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=backend-builder /app/backend/target/release/sigma_backend ./sigma_backend
COPY --from=elm-builder /elm/frontend/dist ./dist
VOLUME ["/data/gnupg"]
EXPOSE 8000
CMD ["./sigma_backend"]
