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
## GITLAB_URL
## GITLAB_CLIENT_ID
## GITLAB_CLIENT_SECRET
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

__URL__="$SCHEME://$HOST_NAME"

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
  __DEFAULT_FROM_EMAIL__="DEFAULT_FROM_EMAIL = \"no-reply@$DOMAIN_NAME\""
  __SERVER_EMAIL__="SERVER_EMAIL = DEFAULT_FROM_EMAIL"
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
  __DEFAULT_FROM_EMAIL__="DEFAULT_FROM_EMAIL = \"$EMAIL_HOST_USER\""
  __SERVER_EMAIL__="SERVER_EMAIL = DEFAULT_FROM_EMAIL"
fi

if [ "$GITLAB_URL" = "" ]
then
  __FRONT_CONFIGS__=""
  __FRONT_PLUGINS__=""
  __BACK_CONFIG1__=""
  __BACK_CONFIG2__=""
  __BACK_CONFIG3__=""
  __BACK_CONFIG4__=""
  __BACK_CONFIG5__=""
else
  __FRONT_CONFIGS__="\"gitLabClientId\": \"$GITLAB_CLIENT_ID\", \"gitLabUrl\": \"$GITLAB_URL\","
  __FRONT_PLUGINS__="\"/plugins/gitlab-auth/gitlab-auth.json\""
  __BACK_CONFIG1__="INSTALLED_APPS += [\"taiga_contrib_gitlab_auth\"]"
  __BACK_CONFIG2__="GITLAB_API_CLIENT_ID = \"$GITLAB_CLIENT_ID\""
  __BACK_CONFIG3__="GITLAB_API_CLIENT_SECRET = \"$GITLAB_CLIENT_SECRET\""
  __BACK_CONFIG4__="GITLAB_URL=\"$GITLAB_URL\""
  __BACK_CONFIG5__="REDIRECT_URI=\"$__URL__/login\""
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
  sed -i "s/__DEFAULT_FROM_EMAIL__/$__DEFAULT_FROM_EMAIL__/g" $2
  sed -i "s/__SERVER_EMAIL__/$__SERVER_EMAIL__/g" $2

  sed -i "s/__FRONT_CONFIGS__/`echo -n ${__FRONT_CONFIGS__//\//\\\/}`/g" $2
  sed -i "s/__FRONT_PLUGINS__/`echo -n ${__FRONT_PLUGINS__//\//\\\/}`/g" $2
  sed -i "s/__BACK_CONFIG1__/`echo -n ${__BACK_CONFIG1__//\//\\\/}`/g" $2
  sed -i "s/__BACK_CONFIG2__/`echo -n ${__BACK_CONFIG2__//\//\\\/}`/g" $2
  sed -i "s/__BACK_CONFIG3__/`echo -n ${__BACK_CONFIG3__//\//\\\/}`/g" $2
  sed -i "s/__BACK_CONFIG4__/`echo -n ${__BACK_CONFIG4__//\//\\\/}`/g" $2
  sed -i "s/__BACK_CONFIG5__/`echo -n ${__BACK_CONFIG5__//\//\\\/}`/g" $2

}

substitute /taiga-back/settings/local.py.tmpl /taiga-back/settings/local.py
substitute /taiga-front-dist/dist/conf.json.tmpl /taiga-front-dist/dist/conf.json 

echo "exec $@"
exec $@
