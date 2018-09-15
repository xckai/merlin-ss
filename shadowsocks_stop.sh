echo "Reset iptables $ ipset"
iptables -t nat -F SS
iptables -t nat -X SS
iptables -t nat -N SS
ipset destroy PROXY_DST
ipset destroy DIRECT_DST
ipset destroy REJECT_DST
echo "Reset dnsmasq"
rm /jffs/configs/dnsmasq.conf.add
service restart_dnsmasq
echo "Kill ss"
ssredir=`pidof ss-redir`
if [ -n "$ssredir" ];then 
	echo_date 关闭ss-redir进程...
	killall ss-redir >/dev/null 
fi
