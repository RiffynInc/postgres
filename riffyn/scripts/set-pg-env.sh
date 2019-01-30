#!/bin/bash 

export PGDATA=/usr/pgdata
export PGHOME=/usr/local/pgsql
export PGAUTOCONF=${PGDATA}/postgresql.auto.conf
export PGHBACONF=${PGDATA}/pg_hba.conf
export PGDATABASENAME=public
export PGUSERNAME=postgres
export PGPASSWD=postgres
export HIVEDATABASENAME=metastore_db
export HIVEUSERNAME=hive_user
export HIVEPASSWD=hive_password

export HIVESCHEMAFILEPATH=/postgres-riffyn-REL_11_STABLE/riffyn/metastore/hive-schema-2.3.0.postgres.sql
export HIVETXNFILEPATH=/postgres-riffyn-REL_11_STABLE/riffyn/metastore/hive-txn-schema-2.3.0.postgres.sql

groupadd -r ${PGUSERNAME} --gid=999
useradd -m -r -g ${PGUSERNAME} --uid=999 ${PGUSERNAME}

su - ${PGUSERNAME}
