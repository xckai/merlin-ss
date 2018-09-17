#! /bin/sh
mkdir shadowsock
d=$(pwd)
cd "$d/shadowsock"
curl -o "$d/shadowsock/update.sh" https://raw.githubusercontent.com/xckai/merlin-ss/master/update.sh
chmod +x "$d/shadowsock/update.sh"
"$d/shadowsock/update.sh" all