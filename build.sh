# 修改build.sh脚本，增加错误处理和重试机制
#!/bin/bash

# 确保安装必要工具
apt-get update && apt-get install -y unzip wget

# 定义下载链接（替换为Alist v3.45.0的正确下载链接）
DOWNLOAD_URL="https://github.com/alist-org/alist/releases/download/v3.45.0/alist-linux-amd64.zip"
FILENAME="alist-linux-amd64.zip"

# 下载文件并增加重试机制
for i in {1..3}; do
    echo "尝试下载Alist ($i/3)..."
    wget -q $DOWNLOAD_URL -O $FILENAME
    
    # 检查文件是否下载成功
    if [ -f $FILENAME ]; then
        # 验证文件大小（根据实际版本修改）
        FILE_SIZE=$(stat -c%s $FILENAME)
        # 这里可以替换为官方发布的文件大小
        EXPECTED_SIZE=10000000  # 示例值，需替换为实际值
        if [ $FILE_SIZE -gt $EXPECTED_SIZE ]; then
            echo "文件下载成功"
            break
        else
            echo "文件大小异常，删除并重试"
            rm -f $FILENAME
        fi
    fi
    sleep 5  # 重试间隔
done

# 检查是否成功下载
if [ ! -f $FILENAME ]; then
    echo "下载Alist失败，退出构建"
    exit 1
fi

# 解压文件并增加错误处理
echo "解压Alist..."
if unzip -q $FILENAME; then
    echo "解压成功"
else
    echo "解压失败，检查ZIP文件是否有效"
    exit 9
fi

# 后续构建步骤...