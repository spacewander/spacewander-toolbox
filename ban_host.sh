#!/usr/bin/env bash

# add a host into /etc/hosts with 127.0.0.1

[ $# != 1 ] && echo "Usage: $0 [hostname like www.weibo.com]"
echo "127.0.0.1    " "$1" | sudo tee -a /etc/hosts
