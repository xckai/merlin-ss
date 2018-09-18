d=$(pwd)
for host in '1' '2' '3'; do
        find=false
        for b in '2' '4';do 
                if [ $host = $b ];then
                        find=true
                        break
                fi
        done
        if [ $find = false ];then
                echo $host
        fi
done