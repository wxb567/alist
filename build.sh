#!/bin/bash
set -e

# 创建临时目录
mkdir -p /tmp/alist && cd /tmp/alist

# 使用 curl 替代 wget 下载 Alist
VERSION=v3.45.0
ARCH=linux-amd64
curl -LO https://github.com/alist-org/alist/releases/download/$VERSION/alist-$ARCH.zip

# 使用预装的 unzip 解压
unzip alist-$ARCH.zip
chmod +x alist

# 创建配置目录
mkdir -p /tmp/alist-data

# 使用环境变量配置（优先）
if [ -n "$ALIST_CONFIG" ]; then
  echo "$ALIST_CONFIG" > /tmp/alist-data/config.json
fi

# 设置管理员账号密码（如果环境变量存在）
if [ -n "$ALIST_USERNAME" ] && [ -n "$ALIST_PASSWORD" ]; then
  ./alist admin "$ALIST_USERNAME" "$ALIST_PASSWORD" --data /tmp/alist-data
fi

# 启动 Alist 并生成静态首页
mkdir -p public
./alist server --port 3000 --data /tmp/alist-data &
sleep 10  # 等待服务启动
curl -o public/index.html http://localhost:3000

# 保持主进程运行
wait $!