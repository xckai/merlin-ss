#! /bin/sh
d=$(pwd)
echo "address=/xckai-pi.ddns.net/192.168.50.75">> "$d/dnsmasq.conf"
service restart_dnsmasq
 