#!/bin/sh

PGDATA=/var/lib/postgresql/9.6/data

if [ -d "$PGDATA" ]
then
        echo "Database Dir Exists"
else
        echo "Database Initialization"
	su postgres -c "pg_ctl init -D $PGDATA"
fi

su postgres -c "echo SELECT 1 AS taiga FROM pg_roles WHERE rolname=\'taiga\' | postgres --single -D $PGDATA" | grep "taiga = \"1\"" > /dev/null

if [ $? = 0 ]
then
        echo "Taiga DB User Exists"
else
        echo "Setup Initial Database"

	su postgres -c "echo CREATE USER taiga WITH PASSWORD \'taiga\' | postgres --single -D $PGDATA"
	su postgres -c "echo CREATE DATABASE taiga OWNER \'taiga\' ENCODING \'UTF-8\' | postgres --single -D $PGDATA"

	su postgres -c "pg_ctl start -D $PGDATA"

	cd /taiga-back
	python3 manage.py migrate --noinput
	python3 manage.py loaddata initial_user
	python3 manage.py loaddata initial_project_templates
	python3 manage.py loaddata initial_role

	su postgres -c "pg_ctl stop -D $PGDATA"
fi

