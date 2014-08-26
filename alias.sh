#!/bin/bash

# 同时向.zsh_aliases和.bash_aliases添加别名
# 用法： alias.sh name alias_name , 
# 比如 alias.sh git.sh gi 或 alias.sh 'rake test' rt

if [ ! $# -eq 2 ]
then
    echo "用法： alia.sh name alias_name, 比如 alias.sh git.sh git"
    exit 1
fi

zsh_aliases="$HOME/.zsh_aliases"
bash_aliases="$HOME/.bash_aliases"

path=$1

# 展开相对路径名
if [[ $1 =~ ^\./ || $1 =~ ^\.\. ]]
then
    path="$(pwd)/$(basename $1)"
fi

cmd=$2

if [ -e "$zsh_aliases" ]
then
    if [[ $path =~ \' ]]
    then
        echo "alias $cmd="'"'"$path"'"' >> "$zsh_aliases"
    else
        echo "alias $cmd='$path'" >> "$zsh_aliases"
    fi
    # bash的source不兼容zsh的alias命令，所以无法source。
    # 如果改成#!..zsh的话，又不能使用basename……
    #source "$zsh_aliases"
else
    echo "$zsh_aliases 不存在！"
fi

if [ -e  "$bash_aliases" ]
then
    if [[ $path =~ \' ]]
    then
        echo "alias $cmd="'"'"$path"'"' >> "$bash_aliases"
    else
        echo "alias $cmd='$path'" >> "$bash_aliases"
    fi
    source "$bash_aliases"
else
    echo "$bash_aliases 不存在！"
fi
