#!/bin/bash

cd `pwd`
# if the input is a directory, use git in it; or use git in pwd
if [[ $# > 0 && -d $1 ]]; 
then
    cd $1
fi

git status
echo 'Press RETURN to continue or use CTRL-C to leave'
read # stop here and read the RETURN

git add -A
git commit 
echo '' # echo an empty line
echo 'the commit will be push to origin/master immediately'
echo 'Press RETURN to continue or use CTRL-C to leave'
read # stop here and read the RETURN

git push origin HEAD:master
git log --stat

