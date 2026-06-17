# Stage 1: Build the MkDocs static site
FROM python:3.13-alpine AS builder

WORKDIR /app

# Install dependencies
COPY pyproject.toml ./
RUN pip install --no-cache-dir mkdocs-material

# Copy docs and config, then build
COPY mkdocs.yml .
COPY docs/ ./docs/

RUN mkdocs build --clean

# Stage 2: Serve with Nginx (tiny ~9MB final image)
FROM nginx:alpine

COPY --from=builder /app/site /usr/share/nginx/html

# Optional: add custom nginx config for SPA-style routing
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
