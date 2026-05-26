# Sử dụng base image là Nginx để phục vụ file tĩnh
FROM nginx:alpine

# Copy file build từ máy của bạn vào thư mục web của Nginx
# Lưu ý: Bạn cần chạy 'flutter build web' ở máy trước khi push
COPY build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]