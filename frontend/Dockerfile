FROM node:18-alpine AS builder

RUN npm install -g elm@latest-0.19.1

WORKDIR /app
COPY elm.json ./
RUN elm make --optimize src/Main.elm

COPY . .
RUN elm make src/Main.elm --optimize --output=dist/main.js

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
