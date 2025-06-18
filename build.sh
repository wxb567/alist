#!/bin/bash
set -e

# 确保 alist 文件有执行权限
chmod +x ./alist

# 显示文件权限信息（用于调试）
echo "alist 文件权限: $(ls -l ./alist)"

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

# 创建静态占位文件（满足 Vercel 要求）
mkdir -p public
echo "Alist 正在运行..." > public/index.html

# 启动 Alist 服务（使用 --bind 参数）
echo "Starting Alist v3.45.0..."
exec ./alist server --bind :$PORT --data /tmp/alist-data