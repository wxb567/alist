#!/bin/bash
set -e

# 创建临时目录
mkdir -p /tmp/alist && cd /tmp/alist

# 下载并解压 Alist（使用 curl 和内置工具）
VERSION=v3.45.0
ARCH=linux-amd64
curl -sLO https://github.com/alist-org/alist/releases/download/$VERSION/alist-$ARCH.zip
unzip -q alist-$ARCH.zip
chmod +x alist

# 创建配置目录
mkdir -p /tmp/alist-data

# 注入配置（如果有环境变量）
if [ -n "$ALIST_CONFIG" ]; then
  echo "$ALIST_CONFIG" > /tmp/alist-data/config.json
fi

# 设置管理员账号（如果有环境变量）
if [ -n "$ALIST_USERNAME" ] && [ -n "$ALIST_PASSWORD" ]; then
  ./alist admin "$ALIST_USERNAME" "$ALIST_PASSWORD" --data /tmp/alist-data >/dev/null 2>&1
fi

# 创建静态占位文件（满足 Vercel 要求）
mkdir -p public
echo "Alist is running..." > public/index.html

# 启动 Alist 服务（后台运行）
./alist server --port $PORT --data /tmp/alist-data &

# 保持主进程运行（使用 tail 替代 wait，减少资源占用）
tail -f /dev/null