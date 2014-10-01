#!/bin/bash

top="$(git rev-parse --show-toplevel)"
result=$?
test $result != 0 && exit $result

cd "$top"

# if the input is a directory, use git in it; or use git in pwd
if [[ $# -gt 0 && -d $1 ]]; 
then
    cd $1
    shift
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

expect -c "set timeout 30;
            spawn -noecho git push origin;
            expect Username* ;
            send -- "$USERNAME"\r;
            expect Password* ;
            send -- "$PASSWORD"\r;
            interact;";

