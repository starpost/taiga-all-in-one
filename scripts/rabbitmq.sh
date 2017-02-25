#!/bin/sh

RABBITMQ_BASE=/var/lib/rabbitmq
RABBITMQ_NODENAME=localhost@localhost
RABBITMQ_PID_FILE=/tmp/rabbitmq.pid

export RABBITMQ_BASE
export RABBITMQ_NODENAME
export RABBITMQ_PID_FILE

rabbitmq-server
