# 一键搭建基于 caddy 的 https(h2) 代理


## 1.一键安装（随机密码 自带临时域名）

```
bash <(curl -L -s git.io/a.sh)
```

## 2.一键安装（自定义账号密码 自定义域名）

```
格式：

bash <(curl -L -s git.io/a.sh) 用户名 密码 你的域名 要伪装的网站

举例：

bash <(curl -L -s git.io/a.sh) admin 888888 www.yourdomian.com www.apple.com
```

## 3.一键卸载

```
bash <(curl -L -s git.io/a.sh) uninstall
```

客户端配置

```
- Chrome:     ProxySwitchyOmega 插件，代理类型选择 https, 端口填443, 再点击右侧的小锁，输入用来验证代理的用户名和密码即可。
- Firefox:    Foxyproxy 插件，配置方式大同小异。
- IOS:        SURGE 等，代理类型选择HTTPS，配置方式大同小异。
- Android:    ProxyDroid、Postern 等，配置方式大同小异。
```

可能用到的命令

```
Debian8 更新系统 安装必要软件：

apt update -y
apt install curl -y

强行释放被占用的端口 以80端口为例：

CMD=`lsof -i:"80" | awk '{print $1}' | grep -v "COMMAND" | sort -u` && systemctl disable ${CMD} && systemctl stop ${CMD} && killall -9 ${CMD}

Debian8 关闭 apache2 ：

systemctl stop apache2
systemctl disable apache2

```

## 关联项目：

https://c2ray.ml

https://github.com/dylanbai8/c2ray



