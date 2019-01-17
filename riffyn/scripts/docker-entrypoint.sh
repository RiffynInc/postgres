#!/bin/bash

# Script to init and (re)start postgres 
# It checks whether it is run first time. If it is running firsttime then it performs follwoing:
#   1. creates postgres group/user and gives ownership of data directory to postgres user/group
#   2. initializes a new cluster
#   3. sets params and access permissions - configures postgres
#   4. 
#   5. Creates users (postgres and hive user), database (public, metastore_db) and loads SQL files (schema and transaction)
# Otherwise it just starts the server.

 
# this are the environment variables which need to be set
PGDATA=${PGDATA}
PGHOME=${PGHOME}
PGAUTOCONF=${PGDATA}/postgresql.auto.conf
PGHBACONF=${PGDATA}/pg_hba.conf
PGDATABASENAME=${PGDATABASE}
PGUSERNAME=${PGUSERNAME}
PGPASSWD=${PGPASSWORD}
HIVEDATABASENAME=${HIVEDATABASENAME}
HIVEUSERNAME=${HIVEUSERNAME}
HIVEPASSWD=${HIVEPASSWD}

# env var for schema and transaction file path
HIVESCHEMAFILEPATH=${HIVESCHEMAFILEPATH}
HIVETXNFILEPATH=${HIVETXNFILEPATH}
 
# create postgres group and user
_pg_create_postgres_user() 
{
    # add postgres system group and user
    # groupadd -r ${PGUSERNAME} --gid=999 
    # useradd -m -r -g ${PGUSERNAME} --uid=999 ${PGUSERNAME}

    # create data dir if not present
    mkdir -p ${PGDATA}

    # get the ownership of the data dir chown ${PGUSERNAME}:${PGUSERNAME} /u01/
    chown -R ${PGUSERNAME}:${PGUSERNAME} ${PGDATA}
    chmod 700 ${PGDATA}
}

# create the database and the user - should be done only once after database cluster has been created.
_pg_create_database_and_user()
{
    ${PGHOME}/bin/psql -c "create user ${PGUSERNAME} with login password '${PGPASSWD}'" postgres
    ${PGHOME}/bin/psql -c "create database ${PGDATABASENAME} with owner = ${PGUSERNAME}" postgres

    ${PGHOME}/bin/psql -c "create user ${HIVEUSERNAME} with login password '${HIVEPASSWD}'" postgres
    ${PGHOME}/bin/psql -c "create database ${HIVEDATABASENAME} with owner = ${HIVEUSERNAME}" postgres

    # load hive schema and transaction schema 
    ${PGHOME}/bin/psql -d ${HIVEDATABASENAME} -U ${HIVEUSERNAME} < ${HIVESCHEMAFILEPATH}
    ${PGHOME}/bin/psql -d ${HIVEDATABASENAME} -U ${HIVEUSERNAME} < ${HIVETXNFILEPATH}
}
 
# start the PostgreSQL instance
_pg_prestart()
{
    USER postgres
    ${PGHOME}/bin/pg_ctl -D ${PGDATA} -w start
}
 
# start postgres and do not disconnect
# required for docker
_pg_start()
{
    USER postgres
    ${PGHOME}/bin/postgres "-D" "${PGDATA}"
}
 
# stop the PostgreSQL instance
_pg_stop()
{
    USER postgres
    ${PGHOME}/bin/pg_ctl -D ${PGDATA} stop -m fast
}
 
# initdb a new cluster
_pg_initdb()
{
    ${PGHOME}/bin/initdb -D ${PGDATA} --data-checksums
}
 
 
# adjust the postgresql parameters
_pg_adjust_config() {
    # PostgreSQL parameters
    echo "listen_addresses = '*'" >> ${PGAUTOCONF}
    echo "logging_collector = 'on'" >> ${PGAUTOCONF}
    echo "log_truncate_on_rotation = 'on'" >> ${PGAUTOCONF}
    echo "log_filename = 'postgresql-%a.log'" >> ${PGAUTOCONF}
    echo "log_rotation_age = '1440'" >> ${PGAUTOCONF}
    echo "log_line_prefix = '%m - %l - %p - %h - %u@%d '" >> ${PGAUTOCONF}
    echo "log_directory = 'pg_log'" >> ${PGAUTOCONF}
    echo "log_min_messages = 'WARNING'" >> ${PGAUTOCONF}
    
    # Authentication settings in pg_hba.conf
    echo "host    all             all             0.0.0.0/0            md5" >> ${PGHBACONF}
}
 
# initialize and start a new cluster
_pg_init_and_start()
{
    # create postgres user and group 
    _pg_create_postgres_user
    USER postgres

    # initialize a new cluster
    _pg_initdb

    # set params and access permissions
    _pg_adjust_config

    # start the new cluster
    _pg_prestart

    # set username and password
    _pg_create_database_and_user
}

# check if $PGDATA exists
if [ -e ${PGDATA} ]; then
    # when $PGDATA exists we need to check if there are files
    # because when there are files we do not want to initdb
    if [ -e "${PGDATA}/base" ]; then
        # when there is the base directory this
        # probably is a valid PostgreSQL cluster
        # so we just start it
        _pg_prestart
    else
        # when there is no base directory then we
        # should be able to initialize a new cluster
        # and then start it
        _pg_init_and_start
    fi
else
    # initialze and start the new cluster
    _pg_init_and_start
    # create PGDATA
    mkdir -p ${PGDATA}
    # create the log directory
    mkdir -p ${PGDATA}/pg_log
fi
# restart and do not disconnect from the postgres daemon
_pg_stop
_pg_start
