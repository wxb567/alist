#!/bin/bash

# 下载最新版Alist
curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install

# 创建必要目录
mkdir -p ./data /etc/aclist

# 复制配置文件
cp config.json /etc/aclist/

# 启动Alist
nohup ./alist "$@" > /dev/null 2>&1 &