# Stage 1: Build Flutter
FROM ubuntu:22.04 AS build
RUN apt-get update && apt-get install -y git curl unzip xz-utils
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve với Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

# Cấu hình Nginx lắng nghe cổng 8001
RUN echo 'server { \
    listen 8001; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8001
CMD ["nginx", "-g", "daemon off;"]