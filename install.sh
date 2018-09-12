entware-setup.sh
opkg install shadowsocks-libev-ss-redir 

iptables -t nat -A PREROUTING -p tcp -m set --set  dst -j REDIRECT --to-port 6666
