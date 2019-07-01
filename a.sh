#!/bin/bash

#====================================================
# 一键搭建基于 caddy 的 https(h2) 代理 [ debian 8 ]
#====================================================



#设置用户名
set_proxy_info(){

user="$1"

[[ -z ${user} ]] && user="username"

pass="$2"

[[ -z ${pass} ]] && pass="password"

domain="$3"
port="443"

touch local_ip.txt && echo `curl -4 ip.sb` >> local_ip.txt && sed "s/./-/" local_ip.txt
[[ -z ${domain} ]] && domain="$(cat local_ip.txt).ip.c2ray.ml:${port}" && rm -rf local_ip.txt

website="$4"

[[ -z ${website} ]] && website="www.stenabulk.com"

}



#清除可能残余的caddy
clean_caddy(){

rm -rf /usr/local/bin/Caddyfile

rm -rf /usr/local/bin/caddy

}



#安装caddy
install_caddy(){

curl https://getcaddy.com | bash -s personal http.forwardproxy,http.proxyprotocol

}



#配置caddy
config_caddy(){

touch /usr/local/bin/Caddyfile

cat <<EOF > /usr/local/bin/Caddyfile
${domain}{
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

rm -rf /www && mkdir /www

wget -c -r -np -k -L -p ${website}

mv ./*${website}*/* /www

}



#重启caddy
restart_caddy(){

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


