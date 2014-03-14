#!/bin/bash

if [ -d $1 ]; # if the input is a directory, use git in it; or use git in pwd
then
    cd $1
fi

git status
echo 'Press RETURN to continue or use CTRL-C to leave'
read # stop here and read the RETURN

read -p "Enter your commit : " Message
while [ -z $Message ]; do
    read -p "Enter your commit : " $Message
done

git add *
git commit -m $Message
echo ''
echo 'the commit will be push to origin/master immediately'
echo 'Press RETURN to continue or use CTRL-C to leave'
read # stop here and read the RETURN

git push origin HEAD:master
