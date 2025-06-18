#!/bin/bash
set -e

# 安装依赖
apt-get update && apt-get install -y wget unzip curl

# 下载 Alist
VERSION=v3.45.0
ARCH=linux-amd64
wget https://github.com/alist-org/alist/releases/download/$VERSION/alist-$ARCH.zip
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

# 启动 Alist 并生成静态首页（注意：这只是为了满足 Vercel 构建要求）
mkdir -p public
./alist server --port 3000 --data /tmp/alist-data &
sleep 10  # 等待服务启动
curl -o public/index.html http://localhost:3000

# 保持主进程运行（Vercel 需要至少一个前台进程）
wait $!