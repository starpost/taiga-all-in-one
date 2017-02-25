#!/bin/sh

PGDATA=/var/lib/postgresql/data

su postgres -c "pg_ctl start -D $PGDATA"

while [ true ]
do
su postgres -c "pg_ctl status -D $PGDATA" || exit 1
sleep 300
done
