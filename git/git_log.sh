#!/bin/sh

# 让我满足的git log。不输出全文，只输出前7位sha标识码，commit日期和commit名
# 已用作gl来代替git log的使用
tmp1="$(mktemp)"
tmp2="$(mktemp)"
tmp3="$(mktemp)"

logNum=15
log="$(git log --oneline --decorate -$logNum)"

echo "$log" | cut -c-7 > "$tmp1"
echo "$log" | cut -c8- > "$tmp2"
# use --date=relative also well
git log --date=short -$logNum | grep 'Date' | cut -c8- > "$tmp3"

paste "$tmp1" "$tmp3" "$tmp2"
