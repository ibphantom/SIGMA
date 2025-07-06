# Stage 1: Build Elm app
FROM node:18-alpine AS builder

WORKDIR /app

# Install Elm
RUN npm install -g elm

# Copy Elm source code and config
COPY elm.json ./
COPY src ./src

# Build Elm to JS (with optimization)
RUN elm make src/Main.elm --optimize --output=dist/elm.js

# Copy static HTML wrapper
COPY dist/index.html ./dist/index.html

# Stage 2: Serve static frontend
FROM node:18-alpine

WORKDIR /app

# Install lightweight HTTP server
RUN npm install -g serve

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["serve", "dist", "-l", "3000"]
