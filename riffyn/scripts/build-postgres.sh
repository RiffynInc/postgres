#!/bin/bash

# PG_VERSION=11.1

# # Copy files
# mkdir -p /riffyn/scripts
# cp riffyn/docker-files/docker-runpoint.sh  /riffyn/scripts/.
# # Copy metastore db-schema and transction-schema files
# cp riffyn/metastore/* /riffyn/scripts/.
# # Copy scripts 
# cp riffyn/scripts/* /riffyn/scripts/.
ls -ll
env

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
   \
   && groupadd -r postgres --gid=999 \
   && useradd -m -r -g postgres --uid=999 postgres \
   && mkdir -p $PGDATA \
   && chown -R postgres:postgres $PGDATA \
   && chmod 700 $PGDATA \
   \
   && ./configure \
   && make \
   && make install \
   && make -C contrib install \
   && rm -rf /home/postgres/src \
   && chown -R postgres:postgres /usr/local/pgsql \
   \
   && apt-get update && apt-get purge --auto-remove -y \
      libldap2-dev \
      libpython-dev \
      libreadline-dev \
      libssl-dev \
      libghc-zlib-dev \
      libcrypto++-dev \
      libxml2-dev \
      libxslt1-dev \
      bzip2 \
      gcc \
      make \
      unzip \
   && apt-get install -y libxml2 \
   && rm -rf /var/lib/apt/lists/*


ls -ll /riffyn/scripts
