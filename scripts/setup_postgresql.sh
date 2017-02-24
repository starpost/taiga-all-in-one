#!/bin/sh

if [ -d /var/lib/postgresql/9.4/main ]
then
        echo "Database Dir Exists"
else
        echo "Database Initialization"
        mkdir -p /var/lib/postgresql/9.4
        chown -R postgres /var/lib/postgresql
        su postgres -c "PGDATA=/var/lib/postgresql/9.4/main /usr/lib/postgresql/9.4/bin/pg_ctl init"
fi

service postgresql start

while [ true ]
do
        /etc/init.d/postgresql status && break
        sleep 1
done

su postgres -c "echo 'SELECT 1' | psql taiga > /dev/null"

if [ $? = 0 ]
then
        echo "Taiga DB User Exists"
else
        echo "Setup Initial Database"

	su postgres -c "psql -c \"CREATE USER taiga WITH PASSWORD 'taiga';\""
	su postgres -c "createdb taiga -O taiga"
	cd /taiga-back
	python manage.py migrate --noinput
	python manage.py loaddata initial_user
	python manage.py loaddata initial_project_templates
	python manage.py loaddata initial_role

fi

service postgresql stop
