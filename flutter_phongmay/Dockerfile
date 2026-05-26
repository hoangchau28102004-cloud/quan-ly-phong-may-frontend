# Sử dụng Ubuntu làm nền tảng
FROM ubuntu:22.04

# Cài đặt các thư viện cần thiết
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Chạy lệnh doctor để xác nhận
RUN flutter doctor

# Thiết lập thư mục làm việc
WORKDIR /app
COPY . .

# Build dự án
RUN flutter pub get
RUN flutter build web --release

# Sử dụng Nginx để phục vụ file tĩnh
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]