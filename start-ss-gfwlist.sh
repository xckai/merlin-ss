ssredir=`pidof ss-redir`
if [ -n "$ssredir" ];then 
	echo_date 关闭ss-redir进程...
	killall ss-redir >/dev/null 
fi
/opt/bin/ss-redir -c /opt/etc/shadowsocks.json -b 0.0.0.0 -u 
#start ss
echo 'reset ipset/iptables'
ipset destroy gfwlist
iptables -t nat -F SS
iptables -t nat -X SS
#prepare
ipset -t nat -N gfwlist iphash
ipset add gfwlist 8.8.8.8
ipset add gfwlist 208.67.222.222
ipset add gfwlist 173.244.217.42
ipset add gfwlist 209.95.56.60
iptables -t nat -N SS
iptables -t nat -A SS -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080
iptables -t nat -A SS -p udp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080
iptables -t nat -A PREROUTING -p tcp -j SS
iptables -t nat -A PREROUTING -p udp -j SS

#prepare dnsamsq


iptables -t nat -A PREROUTING -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080
iptables -t nat -A PREROUTING -p udp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080
echo "Done"