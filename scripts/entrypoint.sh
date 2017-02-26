#!/bin/sh

/scripts/setup_postgresql.sh
/scripts/setup_rabbitmq.sh

## Replace Variables
##
## HOST_NAME    FQDN:PORT
## DOMAIN_NAME  Domain Name
## SECURE       true / false
##
## PUBLIC_REGISTER_ENABLED true / false
## EMAIL_HOST              smtp.gmail.com
## EMAIL_USE_TLS           true / false
## EMAIL_HOST_USER
## EMAIL_HOST_PASSWORD
## EMAIL_PORT              25
##
## __URL__ (http://hostname:port or https://hostname:port)
## __WS_URL__ (ws://hostname:port or wss://hostname:port)
## __SCHEME__ (http / https)
## __WS_SCHEME__ (ws / wss)
## __DOMAIN__ (domain.com)
## 
## __PUBLIC_REGISTER_ENABLED__ (PUBLIC_REGISTER_ENABLED = True)
## __FRONTEND_PUBLIC_REGISTER_ENABLED__ (true/false)
##
## __EMAIL_BACKEND__ (EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend")
## __EMAIL_USE_TLS__ (EMAIL_USE_TLS = False)
## __EMAIL_HOST__ (EMAIL_HOST = "localhost")
## __EMAIL_HOST_USER__ (EMAIL_HOST_USER = "")
## __EMAIL_HOST_PASSWORD__ (EMAIL_HOST_PASSWORD = "")
## __EMAIL_PORT__ (EMAIL_PORT = 25)

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

case "$PUBLIC_REGISTER_ENABLED" in
 "false")
    __PUBLIC_REGISTER_ENABLED__="PUBLIC_REGISTER_ENABLED = False"
    __FRONTEND_PUBLIC_REGISTER_ENABLED__=false
    ;;
 *)
    __PUBLIC_REGISTER_ENABLED__="PUBLIC_REGISTER_ENABLED = True"
    __FRONTEND_PUBLIC_REGISTER_ENABLED__=true
    ;;
esac

if [ "$EMAIL_HOST" = "" ]
then
  __EMAIL_BACKEND__=""
  __EMAIL_USE_TLS__=""
  __EMAIL_HOST__=""
  __EMAIL_HOST_USER__=""
  __EMAIL_HOST_PASSWORD__=""
  __EMAIL_PORT__=""
else
  __EMAIL_BACKEND__='EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"'
  case "$PUBLIC_REGISTER_ENABLED" in
    "true")
      __EMAIL_USE_TLS__="EMAIL_USE_TLS = True"
      ;;
    *)
      __EMAIL_USE_TLS__="EMAIL_USE_TLS = False"
      ;;
  esac
  __EMAIL_HOST__="EMAIL_HOST = \"$EMAIL_HOST\""
  __EMAIL_HOST_USER__="EMAIL_HOST_USER = \"$EMAIL_HOST_USER\""
  __EMAIL_HOST_PASSWORD__="EMAIL_HOST_PASSWORD = \"$EMAIL_HOST_PASSWORD\""
  __EMAIL_PORT__="EMAIL_PORT = $EMAIL_PORT"
fi

substitute() {
  sed "s/__URL__/$SCHEME:\/\/$HOST_NAME/g" $1 > $2 
  sed -i "s/__WS_URL__/$WS_SCHEME:\/\/$HOST_NAME/g" $2
  sed -i "s/__SCHEME__/$SCHEME/g" $2
  sed -i "s/__WS_SCHEME__/$WS_SCHEME/g" $2
  sed -i "s/__DOMAIN__/$DOMAIN_NAME/g" $2

  sed -i "s/__PUBLIC_REGISTER_ENABLED__/$__PUBLIC_REGISTER_ENABLED__/g" $2
  sed -i "s/__EMAIL_BACKEND__/$__EMAIL_BACKEND__/g" $2
  sed -i "s/__EMAIL_USE_TLS__/$__EMAIL_USE_TLS__/g" $2
  sed -i "s/__EMAIL_HOST__/$__EMAIL_HOST__/g" $2
  sed -i "s/__EMAIL_HOST_USER__/$__EMAIL_HOST_USER__/g" $2
  sed -i "s/__EMAIL_HOST_PASSWORD__/$__EMAIL_HOST_PASSWORD__/g" $2
  sed -i "s/__EMAIL_PORT__/$__EMAIL_PORT__/g" $2
  sed -i "s/__FRONTEND_PUBLIC_REGISTER_ENABLED__/$__FRONTEND_PUBLIC_REGISTER_ENABLED__/g" $2
}

substitute /taiga-back/settings/local.py.tmpl /taiga-back/settings/local.py
substitute /taiga-front-dist/dist/conf.json.tmpl /taiga-front-dist/dist/conf.json 

echo "exec $@"
exec $@
