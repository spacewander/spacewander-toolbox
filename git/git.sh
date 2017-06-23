#!/bin/bash

top="$(git rev-parse --show-toplevel)"
result=$?
test $result != 0 && exit $result

cd "$top"
cur_branch="$(git rev-parse --abbrev-ref HEAD)"

# if the input is a directory, use git in it; or use git in pwd
if [[ $# -gt 0 && -d "$1" ]]; 
then
    cd "$1"
    shift
fi

git status
echo 'Press RETURN to continue or use CTRL-C to leave'
read # stop here and read the RETURN

git status --short | grep '^[A|D|M]' > /dev/null
test $? -gt 0 && git add -u
git commit -v
echo '' # echo an empty line
echo "the commit will be push to origin/""$cur_branch"" immediately"
echo 'Press RETURN to continue or use CTRL-C to leave'
read # stop here and read the RETURN

# replace $USERNAME and $PASSWORD to your GitHub username and password
if [[ "$cur_branch" == "master" ]]
then
    expect -c "set timeout 30;
                spawn -noecho git push origin $cur_branch;
                expect Username* ;
                send -- $USERNAME\r;
                expect Password* ;
                send -- $PASSWORD\r;
                interact;";
else
    expect -c "set timeout 30;
                spawn -noecho git push origin --set-upstream $cur_branch;
                expect Username* ;
                send -- $USERNAME\r;
                expect Password* ;
                send -- $PASSWORD\r;
                interact;";

fi
