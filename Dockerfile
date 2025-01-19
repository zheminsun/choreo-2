FROM nginx:latest

# 暴露 80 端口
EXPOSE 80

# 设置工作目录
WORKDIR /app

# 创建非 root 用户，并设置 UID 在 10000 到 20000 之间
RUN useradd -r -u 10001 -g nginx app-user  # UID 设置为 10001

# 复制配置文件和脚本
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh ./

# 安装依赖并下载 Xray
RUN apt-get update && apt-get install -y wget unzip iproute2 && \
    # 下载最新版本的 Xray
    wget -O temp.zip $(wget -qO- "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep -m1 -o "https.*linux-64.*zip") && \
    unzip temp.zip xray geoip.dat geosite.dat && \
    mv xray x && \
    rm -f temp.zip && \
    chmod -v 755 x entrypoint.sh && \
    # 生成配置文件
    echo 'ewogICAgImxvZyI6ewogICAgICAgICJsb2dsZXZlbCI6Indhcm5pbmciLAogICAgICAgICJhY2NlcyI6Ii9kZXYvbnVsbCIsCiAgICAgICAgImVycm9yIjoiL2Rldi9udWxsIgogICAgfSwKICAgICJpbmJvdW5kczpbCiAgICAgICAgewogICAgICAgICAgICAicG9ydCI6MTAwMDAsCiAgICAgICAgICAgICJwcm90b2NvbCI6InZtZXNzIiwKICAgICAgICAgICAgImxpc3RlbiI6IjEyNy4wLjAuMSIsCiAgICAgICAgICAgICJzZXR0aW5ncyI6ewogICAgICAgICAgICAgICAgImNsaWVudHMiOlsKICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICJpZCI6IlVVSUQiLAogICAgICAgICAgICAgICAgICAgICAgICAiYWx0ZXJJZCI6MAogICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgIF0KICAgICAgICAgICAgfSwKICAgICAgICAgICAgInN0cmVhbVNldHRpbmdzIjp7CiAgICAgICAgICAgICAgICAibmV0d29yayI6IndzIiwKICAgICAgICAgICAgICAgICJ3c1NldHRpbmdzIjp7CiAgICAgICAgICAgICAgICAgICAgInBhdGgiOiJWTVVTU19XU1BBVEgiCiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgIH0KICAgICAgICB9LAogICAgICAgIHsKICAgICAgICAgICAgInBvcnQiOjIwMDAwLAogICAgICAgICAgICAicHJvdG9jb2wiOiJ2bGVzcyIsCiAgICAgICAgICAgICJsaXN0ZW4iOiIxMjcuMC4wLjEiLAogICAgICAgICAgICAic2V0dGluZ3MiOnsKICAgICAgICAgICAgICAgICJjbGllbnRzIjpbCiAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICAiaWQiOiJVVUlEIgogICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgIF0sCiAgICAgICAgICAgICAgICAiZGVjcnlwdGlvbiI6Im5vbmUiCiAgICAgICAgICAgIH0sCiAgICAgICAgICAgICJzdHJlYW1TZXR0aW5ncyI6ewogICAgICAgICAgICAgICAgIm5ldHdvcmsiOiJ3cyIsCiAgICAgICAgICAgICAgICAid3NTZXR0aW5ncyI6ewogICAgICAgICAgICAgICAgICAgICJwYXRoIjoiVkxFU1NfV1NQQVRIIgogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgfQogICAgXSwKICAgICJvdXRib3VuZHMiOlsKICAgICAgICB7CiAgICAgICAgICAgICJwcm90b2NvbCI6ImZyZWVkb20iLAogICAgICAgICAgICAic2V0dGluZ3MiOnsKICAgICAgICAgICAgfQogICAgICAgIH0KICAgIF0sCiAgICAiZG5zIjp7CiAgICAgICAgInNlcnZlcnMiOlsKICAgICAgICAgICAgIjguOC44LjgiLAogICAgICAgICAgICAiOC44LjQuNCIsCiAgICAgICAgICAgICJsb2NhbGhvc3QiCiAgICAgICAgXQogICAgfQp9Cg==' > config

# 修改文件和目录权限
RUN chown -R app-user:nginx /app /var/log/nginx /var/run /etc/nginx

# 以非 root 用户运行，UID 设置为 10001
USER 10001

# 设置入口点
ENTRYPOINT [ "./entrypoint.sh" ]
