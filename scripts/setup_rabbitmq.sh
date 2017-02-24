#!/bin/sh

chown -R rabbitmq /var/lib/rabbitmq

service rabbitmq-server start

rabbitmqctl list_users | grep taiga
if [ $? != 0 ]
then 
	rabbitmqctl add_user taiga taiga
	rabbitmqctl add_vhost taiga
	rabbitmqctl set_permissions -p taiga taiga ".*" ".*" ".*"
fi

service rabbitmq-server stop

