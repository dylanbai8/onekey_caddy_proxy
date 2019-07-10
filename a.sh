#!/bin/bash

#====================================================
# 一键搭建基于 caddy 的 https(h2) 代理 [ debian 8 ]
# 项目地址：https://github.com/dylanbai8/onekey_caddy_proxy
#====================================================



#获取配置信息
user="$1"
pass="$2"
domain="$3"
website="$4"



#配置端口和临时根域名
#:::::::::::::::::::::::::::::::::::::

port="443"
domain_root="ip.c2ray.ml"

#:::::::::::::::::::::::::::::::::::::



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
domain="$(cat local_ip.txt).${domain_root}" && rm -rf local_ip.txt
fi

#设置默认随机伪装网站
set_website_num

#清除可能残余的caddy
clean_caddy

#检测端口
check_port

}
set_website_num(){

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



#在menu下设置代理信息
menu_proxy_info(){

echo "按照提示依次设置代理的自定义用户名密码 自定义域名 自定义伪装站点"
echo "如使用默认值（或随机值） 请留空 直接按回车"
echo ""

stty erase '^H' && read -e -p "设置代理用户名：" user
if [ ! ${user} ]; then
user="admin"
fi

stty erase '^H' && read -e -p "设置代理密码：" pass
if [ ! ${pass} ]; then
pass=`cat /dev/urandom | head -n 10 | md5sum | head -c 8`
fi

stty erase '^H' && read -e -p "设置自定义域名：" domain
if [ ! ${domain} ]; then
rm -rf local_ip.txt && touch local_ip.txt
echo `curl -4 ip.sb` >> local_ip.txt && sed -i "s/\./\-/g" "local_ip.txt"
domain="$(cat local_ip.txt).${domain_root}" && rm -rf local_ip.txt
fi

stty erase '^H' && read -e -p "要伪装成的网站（默认请留空）：" website
if [ ! ${website} ]; then
set_website_num
fi

#检测端口
check_port

}



#储存配置信息
storage_proxy_info(){

echo "----------------------------------------------------------"
echo "正在写入配置信息"
echo "----------------------------------------------------------"

rm -rf /usr/local/bin/proxy_info
mkdir /usr/local/bin/proxy_info

touch /usr/local/bin/proxy_info/username
cat <<EOF > /usr/local/bin/proxy_info/username
${user}
EOF

touch /usr/local/bin/proxy_info/password
cat <<EOF > /usr/local/bin/proxy_info/password
${pass}
EOF

touch /usr/local/bin/proxy_info/domain
cat <<EOF > /usr/local/bin/proxy_info/domain
${domain}
EOF

touch /usr/local/bin/proxy_info/port
cat <<EOF > /usr/local/bin/proxy_info/port
${port}
EOF

}



#读取配置信息
read_proxy_info(){

echo "----------------------------------------------------------"
echo "正在读取配置信息"
echo "----------------------------------------------------------"

get_user="$(cat /usr/local/bin/proxy_info/username)"

get_pass="$(cat /usr/local/bin/proxy_info/password)"

get_domain="$(cat /usr/local/bin/proxy_info/domain)"

get_port="$(cat /usr/local/bin/proxy_info/port)"

}



#清除可能残余的caddy
clean_caddy(){

echo "----------------------------------------------------------"
echo "正在清除可能残余的caddy文件（如多次重装）"
echo "----------------------------------------------------------"

systemctl stop caddy

rm -rf /usr/local/bin/Caddyfile
rm -rf /usr/local/bin/proxy_info
rm -rf /usr/local/bin/ssl_for_caddy

}



#安装caddy
install_caddy(){

if [[ -e /usr/local/bin/caddy ]]; then

echo "----------------------------------------------------------"
echo "检测到本机已安装 caddy 跳过执行安装程序"
echo "----------------------------------------------------------"

caddy_tips="使用本机原有的 caddy 程序，如果代理不可用请先执行卸载后重装"

else

echo "----------------------------------------------------------"
echo "正在安装caddy主程序和代理相关插件（约1分钟）"
echo "----------------------------------------------------------"

curl https://getcaddy.com | bash -s personal http.forwardproxy,http.proxyprotocol

caddy_tips="安装已完成，基于 caddy 的 https(h2) 代理（自带website伪装网站）"

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

rm -rf ./*${website}*

}



#重启caddy
restart_caddy(){

echo "----------------------------------------------------------"
echo "正在重启caddy载入配置文件"
echo "----------------------------------------------------------"

systemctl daemon-reload

systemctl restart caddy

}



#检测caddy是否运行
chack_caddy(){

echo "----------------------------------------------------------"
echo "正在检测caddy进程"
echo "----------------------------------------------------------"

if [[ -e /usr/local/bin/caddy ]]; then

status1_caddy="已安装"

else

status1_caddy="未安装"

fi

PIDS=`ps -ef | grep caddy | grep -v grep | awk '{print $2}'`

if [ ! ${PIDS} ]; then

status2_caddy="未运行"

else

status2_caddy="已运行"

fi

}



#检测域名是否已解析
check_domain(){

echo "----------------------------------------------------------"
echo "正在检测域名解析情况"
echo "----------------------------------------------------------"

local_ip=`curl -4 ip.sb`
domain_ip=`ping ${domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`

if [ "${local_ip}" == "${domain_ip}" ]; then
#if [[ $(echo ${local_ip}|tr '.' '+'|bc) -eq $(echo ${domain_ip}|tr '.' '+'|bc) ]];then

status_domain="解析已生效"

else

status_domain="解析未生效 请将自定义域名A记录解析至 ${local_ip} 后重新安装"

fi

}



#检测端口是否被占用
check_port(){

echo "----------------------------------------------------------"
echo "正在检测端口占用情况"
echo "----------------------------------------------------------"

if [[ 0 -eq `lsof -i:"80" | wc -l` ]];then

status_port80="80端口正常"

else

status_port80="80端口异常 可能被其它进程占用"

fi

if [[ 0 -eq `lsof -i:"${port}" | wc -l` ]];then

status_portssl="${port}端口正常"

else

status_portssl="${port}端口异常 可能被其它进程占用"

fi

}



#检测域名ssl证书
chack_ssl(){

echo "----------------------------------------------------------"
echo "正在检测ssl证书情况"
echo "----------------------------------------------------------"

if [[ -e ./.caddy/acme/acme-v02.api.letsencrypt.org/sites/${domain}/${domain}.key ]]; then

status_ssl="已安装"

else

    echo "正在等待签发证书（约1分钟）"
    ssl_get_status
    if [[ -e ./.caddy/acme/acme-v02.api.letsencrypt.org/sites/${domain}/${domain}.key ]]; then
    status_ssl="已安装"
    else
    status_ssl="未安装（新增域名可能需要等待数分钟）"
    fi

fi

}



#检测域名dns ssl证书
chack_dns_ssl(){

echo "----------------------------------------------------------"
echo "正在检测ssl证书情况"
echo "----------------------------------------------------------"

if [[ -e /usr/local/bin/ssl_for_caddy/${domain}.key ]]; then

status_ssl="已安装"

else

status_ssl="未安装（请检查输入的API是否正确）"

fi

}



#等待进度条
ssl_get_status(){

index=0
i=0
bar=''
label=('|' '\\' '-' '/')
while [ $i -le 100 ]
do
    let index=i%4
    let colour=30+$i%8
    echo -en "\e[1;"$colour"m"
    printf "[%-100s][%d%%][%c]\r" "$bar" "$i" "${label[$index]}"
    let i++
    sleep 1
    bar+="■"
    #bar+='□'
    #bar+='#'
done

# 恢复颜色
echo -e "\e[1;30;m"

}



#展示配置信息
show_proxy_info(){

chack_caddy
check_domain
chack_ssl

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
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
echo ""
echo "当前caddy状态：[${status1_caddy}]-[${status2_caddy}]"
echo "当前域名状态：${status_domain}"
echo "当前端口状态：[${status_port80}]-[${status_portssl}]"
echo "当前ssl证书状态：${status_ssl}"
echo ""
echo "${caddy_tips}"
echo "安装路径：/usr/local/bin/ [caddy] [Caddyfile]"
echo "关联项目：https://c2ray.ml"
echo ""

}



#命令执行列表
main(){

set_proxy_info
storage_proxy_info
install_caddy
config_caddy
auto_caddy
website_caddy
restart_caddy
show_proxy_info

}



#卸载caddy
if [ "${user}" == uninstall ]; then

echo "----------------------------------------------------------"
echo "正在执行卸载"
echo "----------------------------------------------------------"

systemctl stop caddy
systemctl disable caddy

rm -rf /usr/local/bin/Caddyfile
rm -rf /usr/local/bin/caddy
rm -rf /etc/systemd/system/caddy.service
rm -rf /www
rm -rf /usr/local/bin/proxy_info
rm -rf /usr/local/bin/ssl_for_caddy

chack_caddy

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
echo "----------------------------------------------------------"
echo ""
echo "caddy已卸载"
echo ""
echo "关联项目：https://c2ray.ml"
echo ""
echo "----------------------------------------------------------"
echo ""
echo "当前caddy状态：[${status1_caddy}]-[${status2_caddy}]"
echo ""

exit
fi



#查看当前代理账号信息
if [[ "${user}" == info ]] && [[ -e /usr/local/bin/Caddyfile ]]; then

echo "----------------------------------------------------------"
echo "开始读取"
echo "----------------------------------------------------------"

    if [[ -e /usr/local/bin/proxy_info/ssl_acme ]]; then
    chack_ssl_path=chack_dns_ssl
    else
    chack_ssl_path=chack_ssl
    fi

read_proxy_info
chack_caddy

domain="${get_domain}"
${chack_ssl_path}

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
echo "----------------------------------------------------------"
echo ""
echo "代理协议：https"
echo ""
echo "代理服务器：${get_domain}"
echo "代理端口：${get_port}"
echo ""
echo "用户名：${get_user}"
echo "密码：${get_pass}"
echo ""
echo "----------------------------------------------------------"
echo ""
echo "当前caddy状态：[${status1_caddy}]-[${status2_caddy}]"
echo "当前ssl证书状态：${status_ssl}"
echo ""
echo "如需要修改用户名密码 重复执行安装时相同的代码即可"
echo "安装路径：/usr/local/bin/ [caddy] [Caddyfile]"
echo "关联项目：https://c2ray.ml"
echo ""
exit

elif [[ "${user}" == info ]]; then

echo "----------------------------------------------------------"
echo "未检测到 caddy 请先安装"
echo "----------------------------------------------------------"

bash <(curl -L -s git.io/a.sh) menu

exit
fi



#修改用户名密码
reset_password(){

if [[ -e /usr/local/bin/Caddyfile ]]; then

echo ""
echo "按照提示依次重设代理的用户名密码"
echo "如使用默认值（或随机值） 请留空 直接按回车"
echo ""

stty erase '^H' && read -e -p "设置代理用户名：" user
if [ ! ${user} ]; then
user="admin"
fi

stty erase '^H' && read -e -p "设置代理密码：" pass
if [ ! ${pass} ]; then
pass=`cat /dev/urandom | head -n 10 | md5sum | head -c 8`
fi

echo "----------------------------------------------------------"
echo "正在将新账号写入配置文件"
echo "----------------------------------------------------------"

touch /usr/local/bin/proxy_info/username
cat <<EOF > /usr/local/bin/proxy_info/username
${user}
EOF

touch /usr/local/bin/proxy_info/password
cat <<EOF > /usr/local/bin/proxy_info/password
${pass}
EOF

sed -i '/^    basicauth/c\    basicauth '"${user}"' '"${pass}"'' /usr/local/bin/Caddyfile

echo "----------------------------------------------------------"
echo "正在重启caddy载入配置文件"
echo "----------------------------------------------------------"

systemctl restart caddy

read_proxy_info
chack_caddy

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
echo "----------------------------------------------------------"
echo ""
echo "代理协议：https"
echo ""
echo "代理服务器：${get_domain}"
echo "代理端口：${get_port}"
echo ""
echo "用户名：${get_user}"
echo "密码：${get_pass}"
echo ""
echo "----------------------------------------------------------"
echo ""
echo "当前caddy状态：[${status1_caddy}]-[${status2_caddy}]"
echo ""
echo "安装路径：/usr/local/bin/ [caddy] [Caddyfile]"
echo "关联项目：https://c2ray.ml"
echo ""

else

clear
echo "----------------------------------------------------------"
echo "未检测到 caddy 请先安装"
echo "----------------------------------------------------------"

bash <(curl -L -s git.io/a.sh) menu

fi

}



#菜单模式menu
if [ "${user}" == menu ]; then

chack_caddy

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
echo "----------------------------------------------------------"
echo ""
echo "1.全自动一键安装（随机密码 自动临时域名 随机伪装站点）"
echo "2.自定义一键安装（自定义账号密码 自定义域名 自定义伪装站点）"
echo ""
echo "3.开启高级伪装抵御探测（独立认证页）、生成智能路由PAC"
echo ""
echo "4.重启caddy"
echo "5.查看当前代理账号信息"
echo ""
echo "6.修改用户名密码"
echo "7.一键卸载"
echo ""
echo "8.彩蛋"
echo "9.退出"
echo ""
echo "----------------------------------------------------------"
echo ""
echo "当前caddy状态：[${status1_caddy}]-[${status2_caddy}]"
echo ""

stty erase '^H' && read -e -p "请输入：" menu_num

case ${menu_num} in

1)
bash <(curl -L -s git.io/a.sh)
;;

2)
menu_proxy_info
bash <(curl -L -s git.io/a.sh) ${user} ${pass} ${domain} ${website}
;;

3)
bash <(curl -L -s git.io/a.sh) pro
;;

4)
if [[ -e /usr/local/bin/Caddyfile ]]; then
systemctl restart caddy
clear
echo "----------------------------------------------------------"
echo "已重启caddy进程 [5]秒钟后返回开始菜单"
echo "----------------------------------------------------------"
sleep 3
bash <(curl -L -s git.io/a.sh) menu
else
clear
echo "----------------------------------------------------------"
echo "未检测到 caddy 请先安装"
echo "----------------------------------------------------------"
bash <(curl -L -s git.io/a.sh) menu
fi
;;

5)
bash <(curl -L -s git.io/a.sh) info
;;

6)
reset_password
;;

7)
bash <(curl -L -s git.io/a.sh) uninstall
;;

8)
bash <(curl -L -s git.io/a.sh) egg
;;

9)
exit
;;

*)
bash <(curl -L -s git.io/a.sh) menu
;;

esac

exit
fi



#彩蛋
if [[ "${user}" == egg ]] && [[ -e /usr/local/bin/Caddyfile ]]; then

echo "----------------------------------------------------------"
echo "正在安装彩蛋"
echo "----------------------------------------------------------"

    if [[ -e /usr/local/bin/proxy_info/ssl_acme ]]; then
    chack_ssl_path=chack_dns_ssl
    else
    chack_ssl_path=chack_ssl
    fi

read_proxy_info
chack_caddy

domain="${get_domain}"
${chack_ssl_path}

rm -rf /www
mkdir /www

wget -r -p -np -k https://chvin.github.io/react-tetris/
wget -r -p -np -k https://chvin.github.io/react-tetris/music.mp3

mv ./chvin.github.io/react-tetris/* /www

rm -rf ./chvin.github.io

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
echo "----------------------------------------------------------"
echo ""
echo "彩蛋安装完成 打开伪装网站查看"
echo "彩蛋地址：https://${get_domain}:${get_port}"
echo ""
echo "代理协议：https"
echo ""
echo "代理服务器：${get_domain}"
echo "代理端口：${get_port}"
echo ""
echo "用户名：${get_user}"
echo "密码：${get_pass}"
echo ""
echo "----------------------------------------------------------"
echo ""
echo "当前caddy状态：[${status1_caddy}]-[${status2_caddy}]"
echo "当前ssl证书状态：${status_ssl}"
echo ""
echo "安装路径：/usr/local/bin/ [caddy] [Caddyfile]"
echo "关联项目：https://c2ray.ml"
echo ""
exit

elif [[ "${user}" == egg ]]; then

bash <(curl -L -s git.io/a.sh)
bash <(curl -L -s git.io/a.sh) egg

exit
fi



#:::::::::::以下所有代码为 通过 DNS API 模式申请 Let’s Encrypt 证书 安装https(h2)代理::::::::::::


#设置cloudflare域名解析api
set_cloudflare_dnsapi(){

clear
echo ""
echo "按照提示依次设置 CloudFlare的 DNS API 接口"
echo "接口申请地址：https://www.cloudflare.com/a/profile"
echo ""

stty erase '^H' && read -e -p "设置 CF_Key 请输入：" CF_Key
if [ ! ${CF_Key} ]; then
set_cloudflare_dnsapi
fi

stty erase '^H' && read -e -p "设置 CF_Email 请输入：" CF_Email
if [ ! ${CF_Email} ]; then
set_cloudflare_dnsapi
fi

export CF_Key="${CF_Key}"
export CF_Email="${CF_Email}"

dns_cmd="dns_cf"

}



#设置dnspod域名解析api
set_dnspod_dnsapi(){

clear
echo ""
echo "按照提示依次设置 腾讯/DNSPod（国内版）DNS API 接口"
echo "接口申请地址：https://www.dnspod.cn/console/user/security"
echo ""

stty erase '^H' && read -e -p "设置 DP_Id 请输入：" DP_Id
if [ ! ${DP_Id} ]; then
set_dnspod_dnsapi
fi

stty erase '^H' && read -e -p "设置 DP_Key 请输入：" DP_Key
if [ ! ${DP_Key} ]; then
set_dnspod_dnsapi
fi

export DP_Id="${DP_Id}"
export DP_Key="${DP_Key}"

dns_cmd="dns_dp"

}



#设置aliyun域名解析api
set_aliyun_dnsapi(){

clear
echo ""
echo "按照提示依次设置 阿里云解析 DNS API 接口"
echo "接口申请地址：https://usercenter.console.aliyun.com/#/manage/ak"
echo ""

stty erase '^H' && read -e -p "设置 Ali_Key 请输入：" Ali_Key
if [ ! ${Ali_Key} ]; then
set_aliyun_dnsapi
fi

stty erase '^H' && read -e -p "设置 Ali_Secret 请输入：" Ali_Secret
if [ ! ${Ali_Secret} ]; then
set_aliyun_dnsapi
fi

export Ali_Key="${Ali_Key}"
export Ali_Secret="${Ali_Secret}"

dns_cmd="dns_ali"

}



#安装acme 使用dns模式申请证书
getssl_with_dnsapi(){

${set_dnsapi}

echo ""
echo "按照提示设置代理（SSL）端口 支持非443端口"
echo ""
stty erase '^H' && read -e -p "设置代理端口：" port
if [ ! ${port} ]; then
port="443"
fi

echo ""
menu_proxy_info

echo "----------------------------------------------------------"
echo "正在安装acme.sh 开始申请ssl证书"
echo "----------------------------------------------------------"

curl https://get.acme.sh | sh

#签发证书
./.acme.sh/acme.sh --issue --dns ${dns_cmd} -d ${domain}

rm -rf /usr/local/bin/ssl_for_caddy
mkdir /usr/local/bin/ssl_for_caddy

#复制证书 设置自动续签
./.acme.sh/acme.sh --install-cert -d ${domain} --cert-file /usr/local/bin/ssl_for_caddy/${domain}.crt --key-file /usr/local/bin/ssl_for_caddy/${domain}.key --reloadcmd "systemctl restart caddy"

}



#选取dns域名服务商
caddy_proxy_for_natvps(){

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
echo "----------------------------------------------------------"
echo ""
echo "即将通过 DNS API 模式申请 Let’s Encrypt 证书 安装https(h2)代理"
echo "适用于 nat vps 或者其它无法通过80端口验证域名的情况"
echo ""
echo "请选择你的域名解析 DNS 服务商："
echo ""
echo "1.CloudFlare 域名解析"
echo "2.腾讯/DNSPod（国内版）"
echo "3.阿里云 域名云解析"
echo ""
echo "注意：API参数将设置储存在本机 acme.sh 环境变量中 勿在不安全的环境中使用"
echo ""

stty erase '^H' && read -e -p "请选择：" api_num

case ${api_num} in

1)
set_dnsapi="set_cloudflare_dnsapi"
;;

2)
set_dnsapi="set_dnspod_dnsapi"
;;

3)
set_dnsapi="set_aliyun_dnsapi"
;;

*)
caddy_proxy_for_natvps
;;

esac

}



#通过 DNS API 模式申请 Let’s Encrypt 证书 安装https(h2)代理
if [ "${user}" == natvps ]; then

caddy_proxy_for_natvps
clean_caddy
getssl_with_dnsapi

storage_proxy_info
install_caddy
config_caddy

#修正Caddyfile
sed -i '/^tls/c\tls /usr/local/bin/ssl_for_caddy/'"${domain}"'.crt /usr/local/bin/ssl_for_caddy/'"${domain}"'.key' /usr/local/bin/Caddyfile

#记录ssl签发模式
touch /usr/local/bin/proxy_info/ssl_acme
cat <<EOF > /usr/local/bin/proxy_info/ssl_acme
ssl_acme
EOF

auto_caddy
website_caddy
restart_caddy

chack_caddy
check_domain
chack_dns_ssl

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
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
echo ""
echo "当前caddy状态：[${status1_caddy}]-[${status2_caddy}]"
echo "当前域名状态：${status_domain}"
echo "当前端口状态：[${status_portssl}]"
echo "当前ssl证书状态：${status_ssl}"
echo ""
echo "${caddy_tips}"
echo "安装路径：/usr/local/bin/ [caddy] [Caddyfile]"
echo "关联项目：https://c2ray.ml"
echo ""

exit
fi



#高级伪装
proxy_mask_pro(){

if [[ -e /usr/local/bin/Caddyfile ]]; then

echo "----------------------------------------------------------"
echo "正在生成高级伪装配置"
echo "----------------------------------------------------------"

read_proxy_info

pac_path=`cat /dev/urandom | head -n 10 | md5sum | head -c 8`

wget -N --no-check-certificate https://raw.githubusercontent.com/petronny/gfwlist2pac/master/gfwlist.pac

rm -rf /www/s
mkdir /www/s
mkdir /www/s/${pac_path}

mv ./gfwlist.pac /www/s/${pac_path}/auto_proxy.pac
sed -i "/^var proxy/c\var proxy = 'HTTPS "${get_domain}":"${get_port}"';" /www/s/${pac_path}/auto_proxy.pac
sed -i '/^            "google.com",/c\            "google.com",\n            "'"${pac_path}"'.'"${get_domain}"'",' /www/s/${pac_path}/auto_proxy.pac

cp /www/s/${pac_path}/auto_proxy.pac /www/s/${pac_path}/auto_proxy.txt

echo "----------------------------------------------------------"
echo "正在写入 Caddyfile"
echo "----------------------------------------------------------"

    if [[ -e /usr/local/bin/proxy_info/ssl_acme ]]; then
    chack_ssl_path=chack_dns_ssl

echo "----------------------------------------------------------"
echo "正在写入 ssl based on acme.sh"
echo "----------------------------------------------------------"

touch /usr/local/bin/Caddyfile

cat <<EOF > /usr/local/bin/Caddyfile
${get_domain}:${get_port} {
tls /usr/local/bin/ssl_for_caddy/${get_domain}.crt /usr/local/bin/ssl_for_caddy/${get_domain}.key
root /www
gzip
index index.html
forwardproxy {
    basicauth ${get_user} ${get_pass}
    hide_ip
    hide_via
    probe_resistance ${pac_path}.${get_domain}
    serve_pac        /s/${pac_path}/all_proxy.pac
    response_timeout 30
    dial_timeout     30
}
}
EOF

    else
    chack_ssl_path=chack_ssl

echo "----------------------------------------------------------"
echo "正在写入 ssl based on caddy"
echo "----------------------------------------------------------"

touch /usr/local/bin/Caddyfile

cat <<EOF > /usr/local/bin/Caddyfile
${get_domain}:${get_port} {
tls admin@${get_domain}
root /www
gzip
index index.html
forwardproxy {
    basicauth ${get_user} ${get_pass}
    hide_ip
    hide_via
    probe_resistance ${pac_path}.${get_domain}
    serve_pac        /s/${pac_path}/all_proxy.pac
    response_timeout 30
    dial_timeout     30
}
}
EOF

    fi

echo "----------------------------------------------------------"
echo "正在重启caddy载入配置文件"
echo "----------------------------------------------------------"

systemctl restart caddy

chack_caddy

domain="${get_domain}"
${chack_ssl_path}

clear
echo "----------------------------------------------------------"
echo ":: 基于 caddy 的 https(h2) 代理（自带website伪装网站）::"
echo "----------------------------------------------------------"
echo ""
echo "已开启 hide_ip(隐藏IP) hide_via(隐藏via头) probe_resistance(隐藏认证页) 抵御探测"
echo "已添加 response_timeout(响应超时) dial_timeout(拨号超时)"
echo "已添加 all_proxy(全局代理PAC) auto_proxy(智能路由PAC)"
echo ""
echo "代理协议：https"
echo "代理服务器：${get_domain}  代理端口：${get_port}"
echo "用户名：${get_user}  密码：${get_pass}"
echo ""
echo "注意：以下信息只显示一次！！ PAC储存在web随机路径 且不含用户名密码 请放心使用！"
echo ""
echo "伪装网站：https://${get_domain}:${get_port}"
echo "认证地址：http://${pac_path}.${get_domain}"
echo "全局 PAC ：https://${get_domain}:${get_port}/s/${pac_path}/all_proxy.pac"
echo "智能 PAC ：https://${get_domain}:${get_port}/s/${pac_path}/auto_proxy.pac"
echo "智能 PAC ：https://${get_domain}:${get_port}/s/${pac_path}/auto_proxy.txt"
echo ""
echo "----------------------------------------------------------"
echo ""
echo "注意：使用时电脑或手机设置完成“代理服务器”或者“PAC(即自动配置脚本)”后需要浏览器首先访问“认证地址”完成认证"
echo ""
echo "当前caddy状态：[${status1_caddy}]-[${status2_caddy}] 当前ssl证书状态：[${status_ssl}]"
echo "安装路径：/usr/local/bin/ [caddy] [Caddyfile]"
echo "关联项目：https://c2ray.ml"
echo ""

else

clear
echo "----------------------------------------------------------"
echo "未检测到 caddy 请先安装"
echo "----------------------------------------------------------"

bash <(curl -L -s git.io/a.sh) menu

fi

}

if [ "${user}" == pro ]; then

proxy_mask_pro

exit
fi



main


