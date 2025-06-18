#!/bin/bash

# 设置执行权限
chmod +x alist

# 创建必要目录
mkdir -p data
mkdir -p data/temp
mkdir -p data/log

# 初始化数据库（如果不存在）
if [ ! -f data/data.db ]; then
    echo "初始化数据库..."
    touch data/data.db
    
    # 生成随机管理员密码
    ADMIN_PASSWORD=$(openssl rand -base64 12)
    echo "初始管理员密码: $ADMIN_PASSWORD"
    
    # 更新配置文件中的密码
    jq --arg password "$ADMIN_PASSWORD" \
       '.initial_admin.password = $password' config.json > config.tmp
    mv config.tmp config.json
fi

# 设置日志文件
touch data/log/log.log