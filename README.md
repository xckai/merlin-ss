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
### Quick install
> - Login your router using SSH, change directory to /opt/etc
> - curl https://raw.githubusercontent.com/xckai/merlin-ss/master/getSS.sh | sh


### Quick start
  - config your shadowsocks' server ,password and encryption method;
  - config your own rules[option] 
    - dst2direct.ip : ip list,router will not proxy those ip ;
    - dst2proxy.ip: ip list, router will proxy those ip;
    - proxy.domain: domain list, router will proxy those domain;
  - using `./shadowsocks.sh updateGFWFile` to update your local GFW rules;
  - using `./shadowsocks.sh updateCustomProxy` to update your own rules;
  - using `./shadowsocks.sh startRouter` to config router's iptables;
  - using `./shadowsocks.sh startSS` to start shadowsock's process;
  - using `./shadowsocks.sh` show the help file.

### Feature
  - support gfwmode mode
  - disable adblock because the domain_block file is too large, it cost too mush resource and suspend the DNSMASQ service. Recommand using pi-hole instead.