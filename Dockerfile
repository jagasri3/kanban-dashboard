FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build


# ---------- Stage 2: Runtime ----------
FROM nginx:alpine

# Create a non-root user and required directories
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    mkdir -p /var/cache/nginx /var/log/nginx /var/run /tmp/nginx && \
    chown -R appuser:appgroup \
    /var/cache/nginx \
    /var/log/nginx \
    /var/run \
    /tmp/nginx \
    /usr/share/nginx/html

# Copy only the production build from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Run as non-root user
USER appuser

# Application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/ || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
