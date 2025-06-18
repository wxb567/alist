#!/bin/bash

# 设置执行权限
chmod +x alist

# 创建必要目录
mkdir -p data
touch data/data.db

# 初始化SQLite数据库
echo "初始化数据库..."
./alist admin random