# Stage 2: Serve
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Cấu hình Nginx lắng nghe cổng $PORT thay vì mặc định là 80
# Sử dụng 'sh -c' để thay thế biến môi trường PORT vào file config
RUN echo 'server { \
    listen ${PORT:-80}; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["sh", "-c", "nginx -g 'daemon off;'"]