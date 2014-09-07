#!/bin/bash

# 让我更加满足的git log。不输出全文，只输出前7位sha标识码，commit日期和
# commit的改动文件数、增减行数
# 已用作gll来代替git log的使用

tmp1="$(mktemp)"
tmp2="$(mktemp)"
tmp3="$(mktemp)"
tmp4="$(mktemp)"
tmp5="$(mktemp)"

logNum=15
# 忽略合并commit记录，因为这些记录不会有修改信息
log="$(git log --no-merges --oneline -$logNum)"

echo "$log" | cut -c-7 > "$tmp1"

# use --date=relative also well
git log --no-merges --date=short -$logNum | grep 'Date' | cut -c8- > "$tmp2"

git log --no-merges --shortstat -$logNum | grep '^ [0-9]' > "$tmp3"

echo "$log" | cut -c9- > "$tmp5"

paste "$tmp1" "$tmp2" "$tmp3" > "$tmp4"

# 交替输出tmp4和tmp5的内容
for (( i = 1; i < logNum - 1; i++ ));
do
    head -$i "$tmp4" | tail -1
    head -$i "$tmp5" | tail -1
    echo ''
done

