#!/bin/sh

service postgresql start

while [ true ]
do
/etc/init.d/postgresql status || exit 1
sleep 5
done
