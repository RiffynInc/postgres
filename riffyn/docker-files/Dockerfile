# vim:set ft=dockerfile:
FROM debian
 
# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
ENV LANG en_US.utf8
ENV PG_MAJOR 11
ENV PG_VERSION 11.1
# ENV PGDATA /volume1/pgdata
ENV PGDATABASE "public" \
    PGUSERNAME "postgres" \
    PGPASSWORD "postgres" 
#     HIVEDATABASENAME "metastore_db" \
#     HIVEUSERNAME "hive_user" \
#     HIVEPASSWD "hive_password"
 
COPY ./postgres.tar /
RUN tar -xvf /postgres.tar

WORKDIR /postgres-riffyn-REL_11_STABLE
RUN cp riffyn/docker-files/* /
 
RUN set -ex \
        && apt-get update && apt-get install -y \
           ca-certificates \
        #  curl \
           procps \
           sysstat \
        #    libldap2-dev \
        #    libpython-dev \
        #    libreadline-dev \
        #    libssl-dev \
           bison \
           flex \
        #    libghc-zlib-dev \
        #    libcrypto++-dev \
        #    libxml2-dev \
           libxml2 \
        #    libxslt1-dev \
        #    bzip2 \
        #    make \
        #    gcc \
        #    unzip \
           python \
           locales \
        \
        && rm -rf /var/lib/apt/lists/* \
        && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \
        && apt-get update \
        && groupadd -r ${PGUSERNAME} --gid=999 \
        && useradd -m -r -g ${PGUSERNAME} --uid=999 ${PGUSERNAME} \
        && su ${PGUSERNAME} -c "make install" \
        && su ${PGUSERNAME} -c "make -C contrib install" \

ENV LANG en_US.utf8
USER ${PGUSERNAME}
EXPOSE 5432
ENTRYPOINT ["/docker-entrypoint.sh"]