ssredir=`pidof ss-redir`
if [ -n "$ssredir" ];then 
	echo_date 关闭ss-redir进程...
	killall ss-redir >/dev/null 
fi

ipset destroy chnroute
iptables -t nat -F SS
iptables -t nat -X SS
#prepare
ipset -t nat -N gfwlist iphash
ipset add chnroute 8.8.8.8
ipset add chnroute 208.67.222.222
ipset add chnroute 
iptables -t nat -N SS
iptables -t nat -A SS -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080
iptables -t nat -A SS -p udp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080
iptables -t nat -A PREROUTING -p tcp -j SS
iptables -t nat -A PREROUTING -p udp -j SS


iptables -t nat -A PREROUTING -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080
iptables -t nat -A PREROUTING -p udp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080



iptables -t nat -A PREROUTING -p tcp -s 192.168.1.0/24 -j REDIRECT --to-ports 1080




iptables -t nat -N SHADOWSOCKS

iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN

# 直连中国 IP
iptables -t nat -A SHADOWSOCKS -p tcp -m set --match-set chnroute dst -j RETURN
iptables -t nat -A SHADOWSOCKS -p icmp -m set --match-set chnroute dst -j RETURN

# 重定向到 ss-redir 端口
iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-port 10800
iptables -t nat -A SHADOWSOCKS -p udp -j REDIRECT --to-port 10800
iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS