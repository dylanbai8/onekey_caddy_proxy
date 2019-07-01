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

#设置默认账号
if [ ! ${user} ]; then
user="admin"
fi

#设置默认密码
if [ ! ${pass} ]; then
pass=`cat /dev/urandom | head -n 10 | md5sum | head -c 8`
fi

#生成默认域名
if [ ! ${domain} ]; then
rm -rf local_ip.txt && touch local_ip.txt
echo `curl -4 ip.sb` >> local_ip.txt && sed -i "s/\./\-/g" "local_ip.txt"
domain="$(cat local_ip.txt).ip.c2ray.ml" && rm -rf local_ip.txt
fi

#设置默认伪装网站
if [ ! ${website} ]; then
website="www.stenabulk.com"
fi

}



#清除可能残余的caddy
clean_caddy(){

echo "----------------------------------------------------------"
echo "正在清除可能残余的caddy文件（如多次重装）"
echo "----------------------------------------------------------"

rm -rf /usr/local/bin/Caddyfile

rm -rf /usr/local/bin/caddy

}



#安装caddy
install_caddy(){

echo "----------------------------------------------------------"
echo "正在安装caddy主程序和代理相关插件"
echo "----------------------------------------------------------"

curl https://getcaddy.com | bash -s personal http.forwardproxy,http.proxyprotocol

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
echo "重启caddy载入配置文件"
echo "----------------------------------------------------------"

systemctl daemon-reload

systemctl restart caddy

}



#展示配置信息
show_proxy_info(){
clear
echo "----------------------------------------------------------"
echo ""
echo "代理协议：Https"
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



main


