#!/usr/bin/env bash

set -ex

if [ "$(uname)" == "Darwin" ]; then
    sw_vers
    top -l 1 -s 0 | grep PhysMem
    sysctl hw
    df -h
    cat /etc/hosts
    sudo scutil --get HostName || true
    sudo scutil --get LocalHostName || true
elif [ "$(uname)" == "Linux" ]; then
    if [ -f /etc/redhat-release ]; then
        sudo yum install -y redhat-lsb
    fi
    lsb_release -a
    free -m
    lscpu
    df -h --total
else
    echo "Unknown system: $(uname)"
    exit 1
fi