#!/bin/sh

RABBITMQ_BASE=/var/lib/rabbitmq
RABBITMQ_NODENAME=taiga
RABBITMQ_PID_FILE=/tmp/rabbitmq.pid

export RABBITMQ_BASE
export RABBITMQ_NODENAME
export RABBITMQ_PID_FILE

chown -R rabbitmq $RABBITMQ_BASE

rabbitmq-server &

rabbitmqctl list_users | grep taiga
if [ $? != 0 ]
then 
	rabbitmqctl add_user taiga taiga
	rabbitmqctl add_vhost taiga
	rabbitmqctl set_permissions -p taiga taiga ".*" ".*" ".*"
fi

rabbitmqctl stop

