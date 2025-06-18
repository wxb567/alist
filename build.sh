#!/bin/bash
set -e

# 安装依赖
apt-get update && apt-get install -y wget unzip

# 下载 Alist（替换为最新版本）
VERSION=v3.45.0  # 查看 https://github.com/alist-org/alist/releases 获取最新版本
ARCH=linux-amd64  # 根据服务器架构选择（如 arm64）
wget https://github.com/alist-org/alist/releases/download/$VERSION/alist-$ARCH.zip
unzip alist-$ARCH.zip
chmod +x alist

# 启动 Alist（后台运行）
./alist server --port $PORT --data /tmp/alist-data &
# 等待服务启动
sleep 5