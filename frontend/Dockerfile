FROM node:18-alpine AS builder

WORKDIR /app
RUN npm install -g elm@0.19.1

COPY frontend/elm.json ./elm.json
COPY frontend/src ./src
RUN mkdir dist && elm make src/Main.elm --optimize --output=dist/elm.js
COPY frontend/dist ./dist

FROM node:18-alpine
WORKDIR /app
RUN npm install -g serve
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["serve", "dist", "-l", "3000"]
