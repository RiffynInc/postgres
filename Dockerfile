# vim:set ft=dockerfile:
FROM debian
 
# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
ENV LANG en_US.utf8
ENV PG_MAJOR 11
ENV PG_VERSION 11.1
ENV PGDATA /u02/pgdata
ENV PGHOME /usr/local/pgsql
ENV PGDATABASE "" \
    PGUSERNAME "" \
    PGPASSWORD "" 
# Hive related env vars
ENV HIVEDATABASENAME "metastore_db" \
   HIVEUSERNAME "hive_user" \
   HIVEPASSWD "hive_password" 

# 
RUN mkdir -p /riffyn/scripts
COPY riffyn/scripts/*.sh  /riffyn/scripts/ 
COPY riffyn/metastore/*.sql  /riffyn/scripts/
COPY riffyn/docker-files/docker-entrypoint.sh /riffyn/scripts/

ENV HIVESCHEMAFILEPATH /riffyn/scripts/hive-schema-2.3.0.postgres.sql \
    HIVETXNFILEPATH /riffyn/scripts/hive-txn-schema-2.3.0.postgres.sql

# RUN pwd
# RUN ls -ll
# WORKDIR /srv/riffyn/postgres_src
# ADD postgres_dist.tar.gz ./
# RUN ls -ll
# RUN tar -xvf /postgres.tar
# RUN ls -ll

# RUN cp riffyn/docker-files/* /
 
######
###### 
RUN set -ex \
     \
     && apt-get update && apt-get install -y \
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
#     && chown postgres:postgres /u01/ \
     && mkdir -p "$PGDATA" \
     && chown -R postgres:postgres "$PGDATA" \
     && chmod 700 "$PGDATA" \
     \
     && ./configure \
         # --enable-integer-datetimes \
         # --enable-thread-safety \
         # --with-pgport=5432 \
         # --prefix=/u01/app/postgres/product/$PG_VERSION \\
         # --with-ldap \
         # --with-python \
         # --with-openssl \
         # --with-libxml \
         # --with-libxslt" \
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
##########
##########
#RUN pwd
#RUN ls -ll
#RUN ls -la riffyn/scripts
#RUN /riffyn/scripts/build-postgres.sh
########
#######

ENV LANG en_US.utf8
USER postgres
EXPOSE 5432
ENTRYPOINT ["bash"]