#!/bin/bash
set -e

# 安装依赖
apt-get update && apt-get install -y wget unzip

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

# 启动 Alist，指定配置文件路径
./alist server --port $PORT --data /tmp/alist-data &
sleep 5