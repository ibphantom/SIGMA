FROM node:18-alpine AS builder

WORKDIR /app
RUN npm install -g elm@0.19.1

COPY elm.json ./
COPY src ./src
RUN elm make src/Main.elm --optimize --output=dist/elm.js

COPY dist ./dist

FROM node:18-alpine
WORKDIR /app
RUN npm install -g serve
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["serve", "dist", "-l", "3000"]
