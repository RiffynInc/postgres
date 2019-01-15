#!/bin/bash

# install dependencies
sudo apt-get update
sudo apt-get install -y \
           bison \
        \
        && rm -rf /var/lib/apt/lists/* \
        && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \

export LANG=en_US.utf8

# configure the system for build
./configure

# build the system
./make
