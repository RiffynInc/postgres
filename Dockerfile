# vim:set ft=dockerfile:
FROM debian
 
# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
ENV LANG en_US.utf8
ENV PG_MAJOR 11
ENV PG_VERSION 11.1.riffyn
# ENV PGDATA /volume1/pgdata
ENV PGDATABASE "public" \
    PGUSERNAME "postgres" \
    PGPASSWORD "postgres" 
#     HIVEDATABASENAME "hive_user" \
#     HIVEUSERNAME "hive_password" \
#     HIVEPASSWD "hive_password"
 
COPY ./riffyn/scripts/docker-entrypoint.sh /
 
RUN set -ex \
        \
        && apt-get update && apt-get install -y \
           ca-certificates \
           curl \
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
        && useradd -m -r -g ${PGUSERNAME} --uid=999 ${PGUSERNAME}
 
ENV LANG en_US.utf8
USER postgres
EXPOSE 5432
ENTRYPOINT ["/docker-entrypoint.sh"]