# Stage 1: Build Flutter Web
FROM ubuntu:22.04 AS build

# Cài đặt các gói phụ trợ cần thiết
RUN apt-get update && apt-get install -y git curl unzip xz-utils libglu1-mesa && rm -rf /var/lib/apt/lists/*

# Clone Flutter SDK bản ổn định (stable)
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Cấu hình Git an toàn để tránh lỗi quyền root trong Docker
RUN git config --global --add safe.directory /usr/local/flutter

# Chạy tiền kiểm tra để Flutter tự nạp các công cụ web
RUN flutter doctor

WORKDIR /app
COPY . .

# === ĐIỂM SỬA CHÍ MẠNG: Nhảy thẳng vào thư mục chứa code Flutter của bạn ===
WORKDIR /app/flutter_phongmay

# Tiến hành lấy thư viện và biên dịch bản Web từ đúng thư mục
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Cấu hình chạy mượt mà với Nginx Alpine
FROM nginx:alpine

# Sửa lại đường dẫn lấy file build chuẩn sau khi đổi WORKDIR
COPY --from=build /app/flutter_phongmay/build/web /usr/share/nginx/html

# Thay thế file cấu hình mặc định bằng biến $PORT động của Railway
CMD sh -c "echo 'server { \
    listen '\"\$PORT\"'; \
    location / { \
        root /usr/share/nginx/html; \
        try_files \$uri \$uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"