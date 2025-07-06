FROM node:18-alpine AS builder

WORKDIR /frontend
RUN npm install -g elm@0.19.1

COPY frontend/elm.json ./
COPY frontend/src ./src

RUN mkdir -p dist \
 && elm make src/Main.elm --optimize --output=dist/elm.js

FROM node:18-alpine
WORKDIR /frontend
RUN npm install -g serve

COPY --from=builder /frontend/dist ./dist

EXPOSE 3000
CMD ["serve", "dist", "-l", "3000"]
