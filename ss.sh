#! /bin/sh
d=$(pwd)
stop(){
    echo "stopping all"
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
    sstunnel=`pidof ss-tunnel`
    if [ -n "$sstunnel" ];then 
        echo "关闭ss-tunnel进程..."
        killall ss-tunnel >/dev/null 
    fi
}
init(){
    iptables -t nat -N SS
    ipset -N PROXY_DST hash:net maxelem 65536
    ipset -N DIRECT_DST hash:net maxelem 65536
    ipset -N REJECT_DST iphash
}
startSS(){
    ssredir=`pidof ss-redir`
    if [ -n "$ssredir" ];then 
        echo "关闭ss-redir进程..."
        killall ss-redir >/dev/null 
    fi
    sstunnel=`pidof ss-tunnel`
    if [ -n "$sstunnel" ];then 
        echo "关闭ss-tunnel进程..."
        killall ss-tunnel >/dev/null 
    fi
    nohup /opt/bin/ss-redir -s $mainserver -p $mainserverport -m $encroptmethod -k $mainserverpwd -l 1080 -b 0.0.0.0 -u >/dev/null 2>&1  &
    nohup /opt/bin/ss-tunnel -s $dnsserver -p $dnsserverport -m $dnsencroptmethod -k $dnsserverpwd -l 5353 -v -b 0.0.0.0 -L 8.8.8.8:53 -u >/dev/null 2>&1  &
}
startgfwmode(){
    stop
    init
    echo "start ss in gfw mode"
    source ./ssconfig.sh
    startSS
    echo "add custome ipset rule"
    for ip in $(cat "$d/dst2direct.ip"); do
        ipset add DIRECT_DST $ip
#        iptables -t nat -A SS -d $ip -j RETURN
    donels
    for ip in $(cat "$d/dst2proxy.ip"); do
        ipset add PROXY_DST $ip
#        iptables -t nat -A SS -d $ip -p udp  -j REDIRECT --to-port 1080
#        iptables -t nat -A SS -d $ip -p tcp  -j REDIRECT --to-port 1080
    done
   
    echo "add dnsmasq rules"
    cp /etc/dnsmasq.conf "$d/dnsmasq.conf"
    ln -s "$d/dnsmasq.conf" /jffs/configs/dnsmasq.conf
    rm -r "$d/dnsmasq.d"
    mkdir "$d/dnsmasq.d"
#    ln -s "$d/domain_block.txt" "$d/dnsmasq.d/domain_block.txt"
    ln -s "$d/gfwlist_gfw.list" "$d/dnsmasq.d/gfwlist.list"
    ln -s "$d/custom_proxy_gfw.list" "$d/dnsmasq.d/custom_proxy.list"
    echo "conf-dir=$d/dnsmasq.d">> "$d/dnsmasq.conf"
#    echo "addn-hosts=$d/host_block.txt">> "$d/dnsmasq.conf"  
    service restart_dnsmasq
    echo "Add iptables rules"
    iptables -t nat -A SS -p all -m set --match-set DIRECT_DST dst -j RETURN
    iptables -t nat -A SS -p udp  -m set --match-set PROXY_DST dst  -j REDIRECT --to-port 1080
    iptables -t nat -A SS -p tcp  -m set --match-set PROXY_DST dst  -j REDIRECT --to-port 1080
    iptables -t nat -A PREROUTING -p all -j SS
    
    echo "All done"

}
startchinamode(){
#     stop
#     init
#     echo "start ss in chinaroute mode"
#     nohup /opt/bin/ss-redir -c /opt/etc/shadowsocks.json -b 0.0.0.0 -u >/dev/null 2>&1  &

#     echo "add custome ipset rule"
#     for ip in $(cat "$d/dst2direct.ip"); do
#         ipset add DIRECT_DST $ip
#     done
#     for ip in $(cat "$d/dst2proxy.ip"); do
#         ipset add PROXY_DST $ip
# #        iptables -t nat -A SS -d $ip -p udp  -j REDIRECT --to-port 1080
# #        iptables -t nat -A SS -d $ip -p tcp  -j REDIRECT --to-port 1080
#     done
#     echo "add ipset rule"
#     for ip in $(cat "$d/china.ip"); do
#         ipset add DIRECT_DST $ip
#     done

#     echo "add dnsmasq rules"
#     cp /etc/dnsmasq.conf "$d/dnsmasq.conf"
#     ln -s "$d/dnsmasq.conf" /jffs/configs/dnsmasq.conf
#     rm -r "$d/dnsmasq.d"
#     mkdir "$d/dnsmasq.d"
# #    ln -s "$d/domain_block.txt" "$d/dnsmasq.d/domain_block.txt"
#     ln -s "$d/gfwlist_china.list" "$d/dnsmasq.d/gfwlist.list"
#     ln -s "$d/custom_proxy_china.list" "$d/dnsmasq.d/custom_proxy.list"
# #    echo "addn-hosts=$d/host_block.txt">> "$d/dnsmasq.conf"
#     echo "conf-dir=$d/dnsmasq.d">> "$d/dnsmasq.conf"
#     service restart_dnsmasq
#     echo "Add iptables rules"
#     iptables -t nat -A SS -d 0.0.0.0/8 -j RETURN
#     iptables -t nat -A SS -d 10.0.0.0/8 -j RETURN
#     iptables -t nat -A SS -d 127.0.0.0/8 -j RETURN
#     iptables -t nat -A SS -d 169.254.0.0/16 -j RETURN
#     iptables -t nat -A SS -d 172.16.0.0/12 -j RETURN
#     iptables -t nat -A SS -d 192.168.0.0/16 -j RETURN
#     iptables -t nat -A SS -d 224.0.0.0/4 -j RETURN
#     iptables -t nat -A SS -d 240.0.0.0/4 -j RETURN
#     iptables -t nat -A SS -p all -m set --match-set DIRECT_DST dst -j RETURN
#     iptables -t nat -A SS -p udp  -j REDIRECT --to-port 1080
#     iptables -t nat -A SS -p tcp  -j REDIRECT --to-port 1080
#     iptables -t nat -A PREROUTING -p all -j SS
#     echo "All done"
}


case "$1" in
        restartss)
            startSS
            ;;
         
        stop)
            stop
            ;;
         
        restart)
            startgfwmode
            ;;
        *)
            echo $"Usage: $0 {restart|startSS|stop}"
            exit 1
 
esac 
