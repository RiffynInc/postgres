#!/bin/bash

PG_VERSION=11.1

# install dependencies
apt-get update
apt-get install -y \
        curl \
        procps \
        sysstat \
        libldap2-dev \
        libpython-dev \
        libreadline-dev \
        libssl-dev \
        bison \
        flex \
        libghc-zlib-dev \
        libcrypto++-dev \
        libxml2-dev \
        libxml2-utils \
        libxslt1-dev \
        bzip2 \
        make \
        gcc \
        unzip \
        python \
        locales \
        \
        && rm -rf /var/lib/apt/lists/* \
        && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \

apt-get update

export LANG=en_US.utf8
export PG_DIST_DIR=postgresql-$PG_VERSION
# export PG_DIST_DIR=$PWD
# configure the system for build
./configure \
   --enable-thread-safety \
    # --with-pgport=5432 \
    --with-ldap \
    # --with-python \
    --with-openssl \
    --with-libxml \
    --with-libxslt

# build the system
make dist

echo "Create tar file from bundle"
tar -czf ../postgres.tar $PG_DIST_DIR
