#!/bin/bash

# traceroute with geographic info
echo traceroute to [$1] from localhost
ip=$1
echo

echo ----显示详细地理位置信息----
mtr --n --report $ip|grep -v Snt|awk 'NR > 1 {
    printf "%-18s  %-10s",  NR - 1") "$2,"  Delay["$4"s]   \n";
    system("whois "$2"|grep -e netname -e descr|cut -c17-");printf "\n"
}'
#echo ----显示简略地理位置信息---
#mtr --n --report $ip|grep -v Snt|awk 'NR > 1 {printf "%-18s  %-10s",  NR - 1 ") "$2,"  Delay["$4"s]   ";system("whois "$2"|grep descr|head -n 1|cut -c17-");printf "\n"}'
