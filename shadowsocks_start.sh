echo "Initialize iptable"
iptables -t nat -F SS
iptables -t nat -X SS
iptables -t nat -N SS
iptables -t nat -A PREROUTING -p tcp -j SS
iptables -t nat -A PREROUTING -p udp -j SS
echo "Initialize ipset"
ipset destroy PROXY_DST
ipset destroy DIRECT_DST
ipset destroy REJECT_DST
ipset -N PROXY_DST iphash
ipset -N DIRECT_DST iphash
ipset -N REJECT_DST iphash
echo "Reset dnsmasq config"
rm /jffs/configs/dnsmasq.conf.add
touch /jffs/configs/dnsmasq.conf.add
echo "Initialize done"


echo "Kill ss"
ssredir=`pidof ss-redir`
if [ -n "$ssredir" ];then 
	echo_date 关闭ss-redir进程...
	killall ss-redir >/dev/null 
fi
echo "Start ss"
nohup /opt/bin/ss-redir -c /opt/etc/shadowsocks.json -b 0.0.0.0 -u &

echo "Add ipset rule"
d=$(pwd)
for ip in $(cat "$d/china.ip"); do
  ipset add DIRECT_DST $ip
done

echo "Add dnsmasq rules"
for rule in $(cat "$d/gfwlist.list"); do
  echo $rule>> /jffs/configs/dnsmasq.conf.add
done
service restart_dnsmasq
echo "Add iptables rules"
iptables -t nat -A SS -p all -m set --match-set DIRECT_DST dst -j RETURN
iptables -t nat -A SS -p all -m set --match-set PROXY_DST dst -j REDIRECT --to-port 1080
