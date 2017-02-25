#!/bin/sh

RABBITMQ_BASE=/var/lib/rabbitmq
RABBITMQ_NODENAME=localhost@localhost
RABBITMQ_PID_FILE=/tmp/rabbitmq.pid

export RABBITMQ_BASE
export RABBITMQ_NODENAME
export RABBITMQ_PID_FILE

chown -R rabbitmq $RABBITMQ_BASE

rabbitmq-server &

while [ true ]
do
	rabbitmqctl status 2>&1 | grep RabbitMQ > /dev/null
	if [ "$?" -eq 0 ]
	then
		echo "RabbitMQ server Started"
		break
	else
		echo "Waiting rabbitmq server to start..."
		sleep 2
	fi
done

rabbitmqctl list_users | grep taiga
if [ $? != 0 ]
then 
	rabbitmqctl add_user taiga taiga
	rabbitmqctl add_vhost taiga
	rabbitmqctl set_permissions -p taiga taiga ".*" ".*" ".*"
fi

rabbitmqctl stop

