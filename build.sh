#!/bin/bash
set -e

# 创建临时目录
mkdir -p /tmp/alist && cd /tmp/alist

# 下载 Alist v3.45.0（选择适合的架构）
VERSION=v3.45.0
ARCH=linux-amd64  # 可选: linux-arm64 (体积更小)
curl -sLO https://github.com/alist-org/alist/releases/download/$VERSION/alist-$ARCH.zip

# 解压并清理
unzip -q alist-$ARCH.zip
chmod +x alist
rm alist-$ARCH.zip

# 创建配置目录
mkdir -p /tmp/alist-data

# 注入配置（从环境变量）
if [ -n "$ALIST_CONFIG" ]; then
  echo "$ALIST_CONFIG" > /tmp/alist-data/config.json
fi

# 设置管理员账号
if [ -n "$ALIST_USERNAME" ] && [ -n "$ALIST_PASSWORD" ]; then
  ./alist admin "$ALIST_USERNAME" "$ALIST_PASSWORD" --data /tmp/alist-data >/dev/null 2>&1
fi

# 创建静态占位文件（满足 Vercel 要求）
mkdir -p public
echo "Alist 正在运行..." > public/index.html

# 启动 Alist 服务
echo "Starting Alist v$VERSION..."
exec ./alist server --port $PORT --data /tmp/alist-data