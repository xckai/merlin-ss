#! /bin/sh
mkdir shadowsock
d=$(pwd)
curl -o "$d/shadowsock/update.sh" https://raw.githubusercontent.com/xckai/merlin-ss/master/update.sh
sh -c "$d/shadowsock/update.sh"