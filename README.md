# merlin-ss

>Quickly install and config ss (both gfwmode and chinaroute mode) for merlin
### Preparation
##### Install Merlin on your ASUS router
> http://asuswrt.lostrealm.ca/
##### Install entware-ng
>https://blog.bluerain.io/p/AsusWrt-Merlin.html
##### Install ss using entware
> - Login router using SSH
> - opkg update
> - opkg install shadowsocks-libev-ss-redir
##### Config your ss
> vi /opt/etc/shadowsocks.json 
> input your ss config,keep ss local port 1080
### Quick install
> - Login your router using SSH, change directory to /opt/etc
> - curl https://raw.githubusercontent.com/xckai/merlin-ss/master/install.sh | sh


### Quick start
  - using `ss.sh gfwmode `to start (!!! if you using chinamode, you should add your ss-server ip into dst2proxy file)
  - you could add update.sh in to a crontab task ,it will update both gfwlist and adblock list by scheduled.
  - you could edit dst2proxy/dst2direct file to custom your router rules.
  - all the domain in proxy.domain file will focused using ss proxy.
### Feature
  - support gfwmode and chinaroute mode
  - disable adblock because the domain_block file is too large, it cost too mush resource and suspend the DNSMASQ service. Recommand using pi-hole instead.