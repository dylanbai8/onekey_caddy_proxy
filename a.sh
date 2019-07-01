#!/bin/bash

#====================================================
# V2ray for mKCP+uTP BT伪装 [ debian 8 ]
#====================================================

update_system(){
apt-get update -y
apt-get install curl -y
apt-get install cron -y

echo ""
echo "----------------------------------------------------------"
echo "系统更新完成、安装 curl cron 完成"
echo "----------------------------------------------------------"
}

install_v2ray(){
bash <(curl -L -s https://install.direct/go.sh)

echo ""
echo "----------------------------------------------------------"
echo "V2ray安装完成"
echo "----------------------------------------------------------"
}

set_config(){
touch /etc/v2ray/config.json
cat <<EOF > /etc/v2ray/config.json
{
  "inbounds": [
    {
      "port": 10303,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "78266cb5-8860-4d12-9095-296f784d4891",
            "alterId": 72
          }
        ]
      },
      "streamSettings": {
        "network": "mkcp",
        "kcpSettings": {
          "uplinkCapacity": 5,
          "downlinkCapacity": 100,
          "congestion": true,
          "header": {
            "type": "utp"
          }
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

echo ""
echo "----------------------------------------------------------"
echo "V2ray配置完成"
echo "----------------------------------------------------------"
}

restart(){
service v2ray restart

echo ""
echo "----------------------------------------------------------"
echo "V2ray载入配置完成"
echo "----------------------------------------------------------"
}

information(){
clear
echo "----------------------------------------------------------"
echo "Port: 10303"
echo "UUID: 78266cb5-8860-4d12-9095-296f784d4891"
echo "alterId: 72"
echo "network: mkcp"
echo "type: utp"
echo "----------------------------------------------------------"
}

auto_restart_update(){
crontab -l >> crontab.txt >/dev/null 2>&1
echo "10 12 * * 1 bash <(curl -L -s https://install.direct/go.sh)" >> crontab.txt
echo "30 12 * * * /sbin/reboot" >> crontab.txt
echo "30 * * * * service v2ray restart" >> crontab.txt
crontab crontab.txt
systemctl restart cron
rm -f crontab.txt

echo ""
crontab -l
echo "----------------------------------------------------------"
echo "已设置：每周一升级 V2ray、每天凌晨重启服务器"
echo "----------------------------------------------------------"
}

main(){
update_system
install_v2ray
set_config
restart
information
auto_restart_update
}

main