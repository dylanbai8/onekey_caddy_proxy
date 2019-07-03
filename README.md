## 一键搭建基于 caddy 的 https(h2) 代理（自带website伪装网站）

注意：安装过程中需要保证80端口443端口开放并未被占用（自动申请ssl证书）

## 方法1. 全自动一键安装（随机密码 自动临时域名 随机伪装站点）

```
bash <(curl -L -s git.io/a.sh)
```

## 方法2. 自定义一键安装（自定义账号密码 自定义域名 自定义伪装站点）

```
[仅自定义用户名密码]

bash <(curl -L -s git.io/a.sh) admin 888888


[自定义域名、伪装网站]

格式：（解析你的域名A记录到服务器IP 按照以下格式执行安装命令）

bash <(curl -L -s git.io/a.sh) 用户名 密码 你的域名 要伪装的网站

举例：

bash <(curl -L -s git.io/a.sh) admin 888888 www.yourdomian.com www.apple.com

或者：

bash <(curl -L -s git.io/a.sh) admin 888888 www.yourdomian.com

```

## 一键卸载

```
bash <(curl -L -s git.io/a.sh) uninstall
```

## 查看当前代理账号信息

```
bash <(curl -L -s git.io/a.sh) showinfo
```

## 菜单模式

## 彩蛋

```
bash <(curl -L -s git.io/a.sh) egg
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
ProxySwitchyOmega 插件下载地址：

https://github.com/FelisCatus/SwitchyOmega/releases
AutoProxy规则列表网址 https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt

关于伪装网站：

伪装网站安装原理为自动抓取下载对方网站首页到自己的服务器
网站内容并无实际意义 仅是取了个捷径省去了自己寻找静态源码
被下载的网站必须是html静态站（最好是html单页面静态站点）
例如：www.stenabulk.com

关于重置密码：

如需要修改用户名密码 重复执行安装时相同的代码即可

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



