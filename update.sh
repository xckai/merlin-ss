
d=$(pwd)
curl -o "$d/file.list" https://raw.githubusercontent.com/xckai/merlin-ss/master/file.list
for file in $(cat "$d/file.list"); do
    curl -o "$d/$file" "https://raw.githubusercontent.com/xckai/merlin-ss/master/$file"
    chmod +x "$d/$file"
done

