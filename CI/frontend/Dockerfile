# --- Builder Stage ---
FROM node:alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps
COPY . .
RUN npm run build

# --- Production Stage ---
FROM node:alpine
WORKDIR /app
RUN npm install express@4.21.1
COPY --from=builder /app/build /app/build
COPY ./entrypoint.sh /app/entrypoint.sh
COPY ./server.js /app/server.js
RUN chmod +x /app/entrypoint.sh
EXPOSE 3000
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["node", "/app/server.js"]