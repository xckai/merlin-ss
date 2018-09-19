
./ss.sh stop
d=$(pwd)
remote_dns='208.67.222.222#5353'

update_chinaip(){
    rm "$d/china.ip"
    curl -o "$d/china.ip" "https://raw.githubusercontent.com/xckai/china_ip_list/master/china_ip_list.txt"
}
update_adblock(){
    rm "$d/host_block.txt"
    rm "$d/domain_block.txt"
    curl -o "$d/domain_block.txt" "https://raw.githubusercontent.com/xckai/hosts-blocklists/master/domains.txt"
    curl -o "$d/host_block.txt" "https://raw.githubusercontent.com/xckai/hosts-blocklists/master/hostnames.txt"
}
update_sh(){
    rm "$d/ss.sh"
    curl -o "$d/ss.sh" "https://raw.githubusercontent.com/xckai/merlin-ss/master/ss.sh"
    chmod +x "$d/ss.sh"
}
update_gfw(){
    echo 'update gfw file'
    rm "$d/gfwlist.txt"
    curl -o "$d/gfwlist.txt" "https://cokebar.github.io/gfwlist2dnsmasq/gfwlist_domain.txt"
    rm "$d/gfwlist_gfw.list"
    rm "$d/gfwlist_china.list"
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
                echo "server=/$host/$remote_dns" >> "$d/gfwlist_china.list"
            fi
        else
            echo "server=/$host/$remote_dns" >> "$d/gfwlist_gfw.list"
            echo "ipset=/$host/PROXY_DST" >> "$d/gfwlist_gfw.list"
            echo "server=/$host/$remote_dns" >> "$d/gfwlist_china.list"
        fi
    done    
}
update_custom(){
    echo "update custom file"
    for file in 'dst2direct.ip' 'dst2proxy.ip' 'proxy.domain' 'direct.domain'; do
        curl -o "$d/$file" "https://raw.githubusercontent.com/xckai/merlin-ss/master/$file"
    done
    rm "$d/custom_proxy_gfw.list"
    rm "$d/custom_proxy_china.list"
    for host in $(cat "$d/proxy.domain"); do
        echo "server=/$host/$remote_dns" >> "$d/custom_proxy_gfw.list"
        echo "ipset=/$host/PROXY_DST" >> "$d/custom_proxy_gfw.list"
        echo "server=/$host/$remote_dns" >> "$d/custom_proxy_china.list"
    done
    for host in $(cat "$d/direct.domain"); do
        echo "ipset=/$host/DIRECT_DST" >> "$d/custom_proxy_gfw.list"
        echo "ipset=/$host/DIRECT_DST" >> "$d/custom_proxy_china.list"
    done
   
   
}
start_ss(){
    "$d/ss.sh" gfwmode
}
case "$1" in
        chinaip)
            update_chinaip
            ;;
         
        gfw)
            update_gfw
            ;;
        adblock)
            update_adblock
            ;;
        custom)
            update_custom
            ;;
        ss)
            update_sh
            ;;
        all)
            update_sh
            update_custom
            update_chinaip
            update_gfw
            ;;
        *)
            echo $"Usage: $0 {ss|adblock|gfw|chinaip|all}"
            exit 1
 
esac 

