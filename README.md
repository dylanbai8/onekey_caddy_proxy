# 一键搭建基于 caddy 的 https(h2) 代理

注意：安装过程中需要保证80端口443端口开放并未被占用（自动申请ssl证书）

## 1.一键安装（随机密码 自带临时域名 随机伪装站点）

```
bash <(curl -L -s git.io/a.sh)
```

## 2.一键安装（自定义账号密码 自定义域名 自定义伪装站点）

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

## 可能用到的命令

```
关于伪装网站：

伪装网站安装原理为自动抓取下载对方网站
被下载的网站必须是html静态站（最好是html单页面静态站点）
例如：www.stenabulk.com

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



