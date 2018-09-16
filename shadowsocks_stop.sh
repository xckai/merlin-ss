d=$(pwd)
echo "Reset iptables $ ipset"
iptables -t nat -F SS
iptables -t nat -X SS
iptables -t nat -N SS
ipset destroy PROXY_DST
ipset destroy DIRECT_DST
ipset destroy REJECT_DST
iptables -t nat -D PREROUTING -p all -j SS
iptables -t nat -D OUTPUT -p all -j SS
echo "Reset dnsmasq"
rm /jffs/configs/dnsmasq.conf.add
rm /jffs/configs/dnsmasq.conf
rm "$d/dnsmasq.conf" 
service restart_dnsmasq
echo "Kill ss"
ssredir=`pidof ss-redir`
if [ -n "$ssredir" ];then 
	echo_date 关闭ss-redir进程...
	killall ss-redir >/dev/null 
fi
