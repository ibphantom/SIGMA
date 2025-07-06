FROM node:18-alpine

# Install Elm and static server
RUN npm install -g elm http-server

# Set working directory
WORKDIR /app

# Copy source
COPY . .

# Compile Elm to JavaScript
RUN elm make src/Main.elm --output=dist/elm.js

# Serve static files
EXPOSE 3000
CMD ["http-server", "dist", "-p", "3000"]
