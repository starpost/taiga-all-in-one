#!/bin/sh

#if [ "$PG_HOST" = "" ]
#then

sleep 2
su postgres -c "psql -c \"CREATE USER taiga WITH PASSWORD 'taiga';\""
su postgres -c "createdb taiga -O taiga"

service rabbitmq-server start
rabbitmqctl add_user taiga taiga
rabbitmqctl add_vhost taiga
rabbitmqctl set_permissions -p taiga taiga ".*" ".*" ".*"
service rabbitmq-server stop

cd /taiga-back
python manage.py migrate --noinput
python manage.py loaddata initial_user
python manage.py loaddata initial_project_templates
python manage.py loaddata initial_role
python manage.py compilemessages
python manage.py collectstatic --noinput

#else
#
#echo "Using external PostgreSQL server: $PG_HOST"
#
#fi
#
