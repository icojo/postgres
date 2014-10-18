#!/bin/bash

if [ "$1" = 'postgres' ]; then
    chown -R postgres "$PGDATA"

    if [ -z "$(ls -A "$PGDATA")" ]; then
        gosu postgres initdb

        sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf

        { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf
    fi

    exec gosu postgres "$@" &

    sleep 5
    psql -U postgres << EOF
create user vj_user;
alter user vj_user password 'vj_password';
create database vj_db with owner vj_user;
EOF
    wait
fi

exec "$@"
