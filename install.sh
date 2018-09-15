#! /bin/sh
mkdir shadowsock
d=$(pwd)
cd "$d/shadowsock"
curl -o "$d/shadowsock/update.sh" https://raw.githubusercontent.com/xckai/merlin-ss/master/update.sh
chmod +x "$d/shadowsock/update.sh"
echo "$d/shadowsock/update.sh"
sh -c "$d/shadowsock/update.sh"