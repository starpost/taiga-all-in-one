#!/bin/sh

service postgresql start

while [ true ]
do
	/etc/init.d/postgresql status && break
	sleep 1
done

su postgresql -c "echo 'SELECT 1' | psql taiga"

if [ $? = 0 ]
then
	exit 0
else
	echo "Setup Initial Database"
	/scripts/setup.sh
fi

echo "exec $@"
exec $@
