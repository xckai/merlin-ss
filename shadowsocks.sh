#! /bin/sh
d=$(pwd)
export mainserver='wow.xukai.iego.net'
export mainserverpwd=
export mainserverport=8457
export encroptmethod='aes-256-cfb'
export dnsserver='wow.xukai.iego.net'
export dnsserverpwd=
export dnsserverport=8457
export dnsencroptmethod='aes-256-cfb'
remote_dns='127.0.0.1#5353'
startRouter(){
    echo 'Start router config  --begin'
    iptables -t nat -N SS
    ipset -N PROXY_DST hash:net maxelem 65536
    ipset -N DIRECT_DST hash:net maxelem 65536
    echo "Add custome ipset rule -dst2direct.ip " 
    for ip in $(cat "$d/dst2direct.ip"); do
        ipset add DIRECT_DST $ip
    done
    echo "Add custome ipset rule -dst2proxy.ip " 
    for ip in $(cat "$d/dst2proxy.ip"); do
        ipset add PROXY_DST $ip
    done
    echo "Add dnsmasq rules"
    cp /etc/dnsmasq.conf "$d/dnsmasq.conf"
    ln -s "$d/dnsmasq.conf" /jffs/configs/dnsmasq.conf
    rm -r "$d/dnsmasq.d"
    mkdir "$d/dnsmasq.d"
    ln -s "$d/gfwlist_gfw.list" "$d/dnsmasq.d/gfwlist.list"
    ln -s "$d/custom_proxy_gfw.list" "$d/dnsmasq.d/custom_proxy.list"
    echo "conf-dir=$d/dnsmasq.d">> "$d/dnsmasq.conf"
    service restart_dnsmasq
    iptables -t nat -A SS -p udp -m set --match-set DIRECT_DST dst -j RETURN
    iptables -t nat -A SS -p tcp -m set --match-set DIRECT_DST dst -j RETURN
    iptables -t nat -A SS -p udp  -m set --match-set PROXY_DST dst  -j REDIRECT --to-port 1080
    iptables -t nat -A SS -p tcp  -m set --match-set PROXY_DST dst  -j REDIRECT --to-port 1080
    iptables -t nat -A PREROUTING -p all -j SS
    echo 'Start router config  --end'
}
stopRouter(){
    echo 'Reset router config  --begin'
    iptables -t nat -D PREROUTING -p all -j SS
    iptables -t nat -F SS
    iptables -t nat -X SS
    ipset destroy PROXY_DST
    ipset destroy DIRECT_DST
    
    rm /jffs/configs/dnsmasq.conf
    rm "$d/dnsmasq.conf"
    service restart_dnsmasq 
    echo 'Reset router config  --done'
}
startSS(){
    if [ -n "$1" ]; then 
        source "$1"
    fi
    echo 'Start shadowsocks process  --begin'
    nohup /opt/bin/ss-redir -s $mainserver -p $mainserverport -m $encroptmethod -k $mainserverpwd -l 1080 -b 0.0.0.0 -u >/dev/null 2>&1  &
    nohup /opt/bin/ss-tunnel -s $dnsserver -p $dnsserverport -m $dnsencroptmethod -k $dnsserverpwd -l 5353 -v -b 0.0.0.0 -L 8.8.8.8:53 -u >/dev/null 2>&1  &
    echo "Main shadowsocks server: $mainserver, port: $mainserverport , local port:1080"
    echo "DNS shadowsocks server:  $dnsserver, remoteDNSPort: $dnsserverport , local DNS port 5353"
    echo 'Start shadowsocks process  --end'
}
stopSS(){
    echo 'Stop shadowsocks process  --begin'
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
    echo 'Stop shadowsocks process  --end'
}
updateGFWFile(){
    echo "Upate GFW domain list --start"
    rm "$d/gfwlist.txt"
    curl -o "$d/gfwlist.txt" "https://cokebar.github.io/gfwlist2dnsmasq/gfwlist_domain.txt"
    rm "$d/gfwlist_gfw.list"
    for host in $(cat "$d/gfwlist.txt"); do
        if [ -f "$d/direct.domain" ];
        then
            find=false
            for direct in $(cat "$d/direct.domain");do 
                    if [ $host = $direct ];then
                            find=true
                            break
                    fi
            done
            if [ $find = false ];then
                echo "server=/$host/$remote_dns" >> "$d/gfwlist_gfw.list"
                echo "ipset=/$host/PROXY_DST" >> "$d/gfwlist_gfw.list"
            fi
        else
            echo "server=/$host/$remote_dns" >> "$d/gfwlist_gfw.list"
            echo "ipset=/$host/PROXY_DST" >> "$d/gfwlist_gfw.list"
        fi
    done
    echo "Upate GFW list --done"
}
updateCustomProxy(){
    echo "Upate custome proxy domain list --start"
    rm "$d/custom_proxy_gfw.list"
    for host in $(cat "$d/proxy.domain"); do
        echo "server=/$host/$remote_dns" >> "$d/custom_proxy_gfw.list"
        echo "ipset=/$host/PROXY_DST" >> "$d/custom_proxy_gfw.list"
    done
    echo "Upate custome proxy domain list --done"
}
restartSS(){
    stopSS
    startSS "$1"
}
reconfigRouter(){
    stopRouter
    startRouter
}
cd "$(dirname "$0")"
case "$1" in
        startRouter)
            startRouter 
            ;;
         
        stopRouter)
            stopRouter
            ;;
         
        startSS)
            startSS "$2"
            ;;
        stopSS)
            stopSS
            ;;
        updateGFWFile)
            updateGFWFile
            ;;
        updateCustomProxy)
            updateCustomProxy
            ;;
        restartSS)
            restartSS
            ;;
        *)
            echo $"Usage: $0 {startRouter|stopRouter|startSS|stopSS|updateGFWFile|updateCustomProxy|restartSS|reconfigRouter}
                            startRouter----Config router's iptable enable customer's rules;
                            stopRouter-----Rest router's iptables clear custmer's rules';
                            startSS--------Start shadowsocks process;
                            stopSS --------Stop shadowsocks process;
                            updateGFWFile--Update GFW rules;
                            updateCustomProxy--Update customer's rules;
                            restartSS -----Stop then start shadowsocks process;
                            reconfigRouter-Rest then reconfig router's customer's iptables rules;
            "
            exit 1
 
esac 