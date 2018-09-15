#! /bin/sh
d=$(pwd)
echo "$d/china.ip"
for ip in $(cat "$d/china.ip"); do
  echo $ip>>"$d/text"
done