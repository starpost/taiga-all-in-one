#!/bin/sh

/scripts/setup_postgresql.sh
/scripts/setup_rabbitmq.sh

## Replace Variables
##
## HOST_NAME    FQDN:PORT
## DOMAIN_NAME  Domain Name
## SECURE       true / false
##
## __URL__ (http://hostname:port or https://hostname:port)
## __WS_URL__ (ws://hostname:port or wss://hostname:port)
## __SCHEME__ (http / https)
## __WS_SCHEME__ (ws / wss)
## __DOMAIN__ (domain.com)
##
## taiga-back/local.py.tmpl -> taiga-back/local.py
## taiga-front/conf.json.tmpl -> taiga-front/conf.json 

case "$SECURE" in
 "true")
    SCHEME=https
    WS_SCHEME=wss
    ;;
 *)
    SCHEME=http
    WS_SCHEME=ws
    ;;
esac

substitute() {
  sed "s/__URL__/$SCHEME:\/\/$HOST_NAME/g" $1 > $2 
  sed -i "s/__WS_URL__/$WS_SCHEME:\/\/$HOST_NAME/g" $2
  sed -i "s/__SCHEME__/$SCHEME/g" $2
  sed -i "s/__WS_SCHEME__/$WS_SCHEME/g" $2
  sed -i "s/__DOMAIN__/$DOMAIN_NAME/g" $2
}

substitute /taiga-back/settings/local.py.tmpl /taiga-back/settings/local.py
substitute /taiga-front-dist/dist/conf.json.tmpl /taiga-front-dist/dist/conf.json 

echo "exec $@"
exec $@
