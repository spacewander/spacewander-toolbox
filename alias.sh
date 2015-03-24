#!/bin/zsh

# 向.zsh_aliases添加别名，或用你喜欢的编辑器修改alias文件
# 用法： alias.sh name alias_name , 
# 比如 alias.sh git.sh gi 或 alias.sh 'rake test' rt

zsh_aliases="$HOME/.zsh_aliases"
bash_aliases="$HOME/.bash_aliases"

if [ ! -e "$zsh_aliases" ]
then
    echo "$zsh_aliases 不存在！"
fi
if [ ! -e "$bash_aliases" ]
then
    echo "$bash_aliases 不存在！"
fi

if [ ! $# -eq 2 ]
then
    if [ $# -eq 1 ]
    then
        test -n "$EDITOR" && EDITOR=/etc/alternatives/editor
        case $1 in
            -b )
                "$EDITOR" "$bash_aliases"
                source "$bash_aliases"
                ;;
            -z )
                "$EDITOR" "$zsh_aliases"
                source "$zsh_aliases"
                ;;
            * )
                echo "用法： alia.sh name alias_name, 比如 alias.sh git.sh git"
        esac
    fi
    exit 0
fi

path=$1

# 展开相对路径名
if [[ $1 =~ ^\./ || $1 =~ ^\.\. ]]
then
    path="$(pwd)/$(basename $1)"
fi

cmd=$2

if [[ $path =~ \' ]]
then
    echo "alias $cmd="'"'"$path"'"' >> "$zsh_aliases"
else
    echo "alias $cmd='$path'" >> "$zsh_aliases"
fi
source "$zsh_aliases"

#if [ -e  "$bash_aliases" ]
#then
    #if [[ $path =~ \' ]]
    #then
        #echo "alias $cmd="'"'"$path"'"' >> "$bash_aliases"
    #else
        #echo "alias $cmd='$path'" >> "$bash_aliases"
    #fi
    #source "$bash_aliases"
#else
    #echo "$bash_aliases 不存在！"
#fi
