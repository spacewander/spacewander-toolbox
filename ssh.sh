#!/bin/bash
auto_login_ssh () {
    expect -c "set timeout -1;
                spawn -noecho ssh -o StrictHostKeyChecking=no $2 ${@:3};
                expect *assword:*;
                send -- $1\r;
                interact;";
} 
password=''
account=''
auto_login_ssh $password '-o ServerAliveInterval=60 '$account

