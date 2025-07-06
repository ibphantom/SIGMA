FROM node:18-alpine AS builder

WORKDIR /app
RUN npm install -g elm@0.19.1

COPY frontend/elm.json frontend/src/ ./frontend/
RUN mkdir -p frontend/dist \
 && elm make frontend/src/Main.elm --optimize --output=frontend/dist/elm.js

FROM node:18-alpine
WORKDIR /app
RUN npm install -g serve
COPY --from=builder /app/frontend/dist ./dist
EXPOSE 3000
CMD ["serve", "dist", "-l", "3000"]
