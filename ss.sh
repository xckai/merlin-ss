#! /bin/sh
d=$(pwd)
stop(){
    echo "stopping all"
    echo "reset iptables $ ipset"
    iptables -t nat -F SS
    iptables -t nat -X SS
    ipset destroy PROXY_DST
    ipset destroy DIRECT_DST
    ipset destroy REJECT_DST
    iptables -t nat -D PREROUTING -p all -j SS
    echo "reset dnsmasq"
    rm /jffs/configs/dnsmasq.conf
    rm "$d/dnsmasq.conf" 
    service restart_dnsmasq
    echo "killing ss"
    ssredir=`pidof ss-redir`
    if [ -n "$ssredir" ];then 
        echo "关闭ss-redir进程..."
        killall ss-redir >/dev/null 
    fi
}
init(){
    iptables -t nat -N SS
    ipset -N PROXY_DST hash:net maxelem 65536
    ipset -N DIRECT_DST hash:net maxelem 65536
    ipset -N REJECT_DST iphash
}
startchinamode(){
    stop
    init
    echo "start ss"
    nohup /opt/bin/ss-redir -c /opt/etc/shadowsocks.json -b 0.0.0.0 -u >/dev/null 2>&1  &

    echo "add custome ipset rule"
    for ip in $(cat "$d/dst2direct.ip"); do
        iptables -t nat -A SS -d $ip -j RETURN
    done
    for ip in $(cat "$d/dst2proxy.ip"); do
        iptables -t nat -A SS -d $ip -p udp  -j REDIRECT --to-port 1080
        iptables -t nat -A SS -d $ip -p tcp  -j REDIRECT --to-port 1080
    done
    echo "add ipset rule"
    for ip in $(cat "$d/china.ip"); do
        ipset add DIRECT_DST $ip
    done

    echo "add dnsmasq rules"
    cp /etc/dnsmasq.conf "$d/dnsmasq.conf"
    ln -s "$d/dnsmasq.conf" /jffs/configs/dnsmasq.conf
    echo "conf-file=$d/domain_block.txt" >> "$d/dnsmasq.conf"
    echo "addn-hosts=$d/host_block.txt">> "$d/dnsmasq.conf"
    rm "$d/gfwlist.list"
    for host in $(cat "$d/gfwlist.txt"); do
        echo "server=/$host/208.67.222.222#5353" >> "$d/gfwlist.list"
    done
    rm "$d/custom_proxy.list"
    for host in $(cat "$d/custom_proxy.txt"); do
        echo "server=/$host/208.67.222.222#5353" >> "$d/custom_proxy.list"
    done
    echo "conf-file=$d/gfwlist.list">> "$d/dnsmasq.conf"
    echo "conf-file=$d/custom_proxy.list">> "$d/dnsmasq.conf"
    service restart_dnsmasq
    echo "Add iptables rules"
    iptables -t nat -A SS -d 0.0.0.0/8 -j RETURN
    iptables -t nat -A SS -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A SS -d 127.0.0.0/8 -j RETURN
    iptables -t nat -A SS -d 169.254.0.0/16 -j RETURN
    iptables -t nat -A SS -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A SS -d 192.168.0.0/16 -j RETURN
    iptables -t nat -A SS -d 224.0.0.0/4 -j RETURN
    iptables -t nat -A SS -d 240.0.0.0/4 -j RETURN
    iptables -t nat -A SS -p all -m set --match-set DIRECT_DST dst -j RETURN
    iptables -t nat -A SS -p udp  -j REDIRECT --to-port 1080
    iptables -t nat -A SS -p tcp  -j REDIRECT --to-port 1080
    iptables -t nat -A PREROUTING -p all -j SS
    echo "All done"
}

startgfwmode(){
    stop
    init
    echo "start ss"
    nohup /opt/bin/ss-redir -c /opt/etc/shadowsocks.json -b 0.0.0.0 -u >/dev/null 2>&1  &

    echo "add custome ipset rule"
    for ip in $(cat "$d/dst2direct.ip"); do
        iptables -t nat -A SS -d $ip -j RETURN
    done
    for ip in $(cat "$d/dst2proxy.ip"); do
        iptables -t nat -A SS -d $ip -p udp  -j REDIRECT --to-port 1080
        iptables -t nat -A SS -d $ip -p tcp  -j REDIRECT --to-port 1080
    done
   
    echo "add dnsmasq rules"
    cp /etc/dnsmasq.conf "$d/dnsmasq.conf"
    ln -s "$d/dnsmasq.conf" /jffs/configs/dnsmasq.conf
    echo "conf-file=$d/domain_block.txt" >> "$d/dnsmasq.conf"
    echo "addn-hosts=$d/host_block.txt">> "$d/dnsmasq.conf"
    rm "$d/gfwlist.list"
    for host in $(cat "$d/gfwlist.txt"); do
        echo "server=/$host/208.67.222.222#5353" >> "$d/gfwlist.list"
        echo "ipset=/$host/PROXY_DST" >> "$d/gfwlist.list"
    done
    rm "$d/custom_proxy.list"
    for host in $(cat "$d/custom_proxy.txt"); do
        echo "server=/$host/208.67.222.222#5353" >> "$d/custom_proxy.list"
        echo "ipset=/$host/PROXY_DST" >> "$d/gfwlist.list"
    done
    echo "conf-file=$d/gfwlist.list">> "$d/dnsmasq.conf"
    echo "conf-file=$d/custom_proxy.list">> "$d/dnsmasq.conf"
    service restart_dnsmasq
    echo "Add iptables rules"
    iptables -t nat -A SS -p all -m set --match-set DIRECT_DST dst -j RETURN
    iptables -t nat -A SS -p udp  -m set --match-set PROXY_DST dst  -j REDIRECT --to-port 1080
    iptables -t nat -A SS -p tcp  -m set --match-set PROXY_DST dst  -j REDIRECT --to-port 1080
    iptables -t nat -A PREROUTING -p all -j SS
    
    echo "All done"

}
case "$1" in
        startchinamode)
            startchinamode
            ;;
         
        stop)
            stop
            ;;
         
        startgfwmode)
            startgfwmode
            ;;
        *)
            echo $"Usage: $0 {startchinamode|startgfwmode|stop|install}"
            exit 1
 
esac 
