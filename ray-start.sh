#!/bin/bash

# 脚本执行失败时退出
set -e

echo "开始安装和配置V2Ray..."

# 1. 下载安装脚本
echo "下载安装脚本..."
wget https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh

# 2. 执行下载的脚本
echo "执行安装脚本..."
bash install-release.sh

# 3. 修改v2ray.service文件
echo "修改systemd服务文件..."
SERVICE_FILE="/etc/systemd/system/v2ray.service"

if [ -f "$SERVICE_FILE" ]; then
    # 检查是否已经存在该配置
    if ! grep -q "V2RAY_VMESS_AEAD_FORCED=false" "$SERVICE_FILE"; then
        # 在[Service]块下添加环境变量
        sed -i '/\[Service\]/a Environment="V2RAY_VMESS_AEAD_FORCED=false"' "$SERVICE_FILE"
        echo "已添加环境变量到服务文件"
    else
        echo "环境变量已存在，跳过修改"
    fi
else
    echo "错误：服务文件 $SERVICE_FILE 不存在"
    exit 1
fi

# 4. 修改配置文件
echo "修改V2Ray配置文件..."
CONFIG_FILE="/usr/local/etc/v2ray/config.json"
CONFIG_CONTENT='{
  "inbound": {
    "port": 8989,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "5d5e82cc-174c-472b-919a-f44548b798c4",
          "alterId": 64
        }
      ]
    },
    "streamSettings": {
      "network":"ws"
    }
  },
  "outbound": {
    "protocol": "freedom", 
    "settings": {}
  }
}'

# 创建配置目录（如果不存在）
mkdir -p /usr/local/etc/v2ray

# 写入配置文件
echo "$CONFIG_CONTENT" > "$CONFIG_FILE"
echo "配置文件已更新"

# 5. 重新加载systemd并启动服务
echo "重新加载systemd配置..."
systemctl daemon-reload

echo "启动V2Ray服务..."
systemctl start v2ray

echo "检查服务状态..."
systemctl status v2ray --no-pager -l

echo "安装和配置完成！"
echo "V2Ray已启动，监听端口：8989"
echo "UUID: 5d5e82cc-174c-472b-919a-f44548b798c4"
echo "alterId: 64"
echo "传输协议: WebSocket"
