# Stage 1: Build Elm frontend
FROM node:18-alpine as builder

WORKDIR /app

# Install Elm and copy source
RUN npm install -g elm
COPY frontend/elm.json frontend/src/ ./frontend/

# Build Elm app to dist/
RUN cd frontend && elm make src/Main.elm --optimize --output=dist/elm.js

# Stage 2: Serve static files
FROM node:18-alpine

WORKDIR /app
RUN npm install -g serve

# Copy static assets
COPY --from=builder /app/frontend/dist ./dist

# Serve static frontend
EXPOSE 3000
CMD ["serve", "dist", "-l", "3000"]
