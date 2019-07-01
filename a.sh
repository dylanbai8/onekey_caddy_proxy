#!/bin/bash

#====================================================
# 一键搭建基于 caddy 的 https(h2) 代理 [ debian 8 ]
#====================================================



#获取配置信息
user="$1"
pass="$2"
domain="$3"
website="$4"

#配置端口
port="443"



#设置代理信息
set_proxy_info(){

echo "----------------------------------------------------------"
echo "正在生成代理信息"
echo "----------------------------------------------------------"

#设置默认用户名
if [ ! ${user} ]; then
user="admin"
fi

#设置默认随机密码
if [ ! ${pass} ]; then
pass=`cat /dev/urandom | head -n 10 | md5sum | head -c 8`
fi

#生成默认域名
if [ ! ${domain} ]; then
rm -rf local_ip.txt && touch local_ip.txt
echo `curl -4 ip.sb` >> local_ip.txt && sed -i "s/\./\-/g" "local_ip.txt"
domain="$(cat local_ip.txt).ip.c2ray.ml" && rm -rf local_ip.txt
fi

#设置默认随机伪装网站
sitenum=`shuf -n 1 -e 1 2 3 4 5 6 7 8`
if [[ ! ${website} ]] && [[ ${sitenum} -eq 1 ]]; then
website="www.ibm.com"
elif [[ ! ${website} ]] && [[ ${sitenum} -eq 2 ]]; then
website="www.stenabulk.com"
elif [[ ! ${website} ]] && [[ ${sitenum} -eq 3 ]]; then
website="www.qualcomm.com"
elif [[ ! ${website} ]] && [[ ${sitenum} -eq 4 ]]; then
website="tw.longchamp.com"
elif [[ ! ${website} ]] && [[ ${sitenum} -eq 5 ]]; then
website="www.apple.com"
elif [[ ! ${website} ]] && [[ ${sitenum} -eq 6 ]]; then
website="www.rodesk.com"
elif [[ ! ${website} ]] && [[ ${sitenum} -eq 7 ]]; then
website="www.adidas.com.cn"
elif [[ ! ${website} ]] && [[ ${sitenum} -eq 8 ]]; then
website="www.frontlynk.com"
fi

}



#清除可能残余的caddy
clean_caddy(){

echo "----------------------------------------------------------"
echo "正在清除可能残余的caddy文件（如多次重装）"
echo "----------------------------------------------------------"

rm -rf /usr/local/bin/Caddyfile

}



#安装caddy
install_caddy(){

if [[ -e /usr/local/bin/caddy ]]; then

echo "----------------------------------------------------------"
echo "检测到caddy已安装跳过安装程序"
echo "----------------------------------------------------------"

else

echo "----------------------------------------------------------"
echo "正在安装caddy主程序和代理相关插件"
echo "----------------------------------------------------------"

curl https://getcaddy.com | bash -s personal http.forwardproxy,http.proxyprotocol

fi

}



#配置caddy
config_caddy(){

echo "----------------------------------------------------------"
echo "正在配置Caddyfile"
echo "----------------------------------------------------------"

touch /usr/local/bin/Caddyfile

cat <<EOF > /usr/local/bin/Caddyfile
${domain}:${port} {
tls admin@${domain}
root /www
gzip
index index.html
forwardproxy {
    basicauth ${user} ${pass}
}
}
EOF

}



#开机自启动caddy
auto_caddy(){

echo "----------------------------------------------------------"
echo "正在配置caddy开机自启动"
echo "----------------------------------------------------------"

touch /etc/systemd/system/caddy.service

cat <<EOF > /etc/systemd/system/caddy.service
[Unit]
Description=Caddy_Server
After=network.target
Wants=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/caddy -conf=/usr/local/bin/Caddyfile -agree=true -ca=https://acme-v02.api.letsencrypt.org/directory
RestartPreventExitStatus=23
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

systemctl enable caddy

}



#安装伪装网站
website_caddy(){

echo "----------------------------------------------------------"
echo "正在安装静态伪装网站"
echo "----------------------------------------------------------"

rm -rf /www
mkdir /www

wget -c -r -np -k -L -p ${website}

mv ./*${website}*/* /www

}



#重启caddy
restart_caddy(){

echo "----------------------------------------------------------"
echo "正在重启caddy载入配置文件"
echo "----------------------------------------------------------"

systemctl daemon-reload

systemctl restart caddy

}



#展示配置信息
show_proxy_info(){
clear
echo "----------------------------------------------------------"
echo ""
echo "代理协议：https"
echo ""
echo "代理服务器：${domain}"
echo "代理端口：${port}"
echo ""
echo "用户名：${user}"
echo "密码：${pass}"
echo ""
echo "----------------------------------------------------------"
}



#命令执行列表
main(){
set_proxy_info
clean_caddy
install_caddy
config_caddy
auto_caddy
website_caddy
restart_caddy
show_proxy_info
}



if [ ${user} = uninstall ]; then

systemctl stop caddy
systemctl disable caddy

rm -rf /usr/local/bin/Caddyfile
rm -rf /usr/local/bin/caddy
rm -rf /etc/systemd/system/caddy.service

fi

clear
echo "----------------------------------------------------------"
echo ""
echo "caddy已卸载"
echo ""
echo "关联项目：https://c2ray.ml"
echo ""
echo "----------------------------------------------------------"

main


