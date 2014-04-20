#!/bin/bash

cd `pwd`
# if the input is a directory, use svn in it; or use svn in pwd
if [[ $# > 0 && -d $1 ]]; 
then
    cd $1
fi

svn status
echo 'Press RETURN to continue or use CTRL-C to leave'
read # stop here and read the RETURN

svn add *
svn commit 
svn update
svn log

