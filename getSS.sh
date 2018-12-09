d=$(pwd)
for file in 'dst2direct.ip' 'dst2proxy.ip' 'proxy.domain' 'direct.domain' 'shadowsocks.sh'; do
        curl -o "$d/$file" "https://raw.githubusercontent.com/xckai/merlin-ss/master/$file"
done
chmod +x "$d/shadowsocks.sh"