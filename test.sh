d=$(pwd)
for host in $(cat "$d/custom_proxy.txt"); do
        echo "server=/$host/8.8.8.8" >>"$d/custome"
done