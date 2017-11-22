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

status="$(git status --short)"
echo "$status" | grep '^[A|D|M]' > /dev/null
if [[ $? -gt 0 ]]; then
    echo "$status" | grep '^ [A|D|M]' > /dev/null
    if [[ $? -gt 0 ]]; then
        # if there is new files only, run `git add -A` to add them
        git add -A
    else
        # if there is not staged change, run `git add -u` to add unstaged changes
        git add -u
    fi
fi
git commit -v
echo '' # echo an empty line
remote=$(git config branch.$cur_branch.remote)
if [ -z "$remote" ]
then
    remote=origin
fi
echo "the commit will be push to ""$remote""/""$cur_branch"" immediately"
echo 'Press RETURN to continue or use CTRL-C to leave'
read -r # stop here and read the RETURN
git push "$remote" --set-upstream "$cur_branch"
