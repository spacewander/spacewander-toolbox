#!/bin/sh

if [ $# -lt 2 ]
then
    echo "usage: $0 tarfile docsetName"
    exit 1
fi

filename=$(basename "$1")
extension="${filename##*.}"
filename="${filename%.*}"

if [ -z "$(which bsdtar)" ]
then
    echo "bsdtar is need!"
    exit 1
else
    case $extension in
        "tgz" )
        echo "extract ""$filename"".tgz to ""$filename"".docset"
        bsdtar -zxf "$filename"".tgz" "$filename"".docset"
        ;;
    esac
fi
