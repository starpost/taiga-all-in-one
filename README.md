Container Configuration
=======================

## Environment Variable Setup

```
-e HOST_NAME=example.com:8888
-e DOMAIN_NAME=example.com
-e SECURE=false
-e PUBLIC_REGISTER_ENABLED=true
-e EMAIL_HOST=smtp.gmail.com
-e EMAIL_USE_TLS=true
-e EMAIL_HOST_USER=user@gmail.com
-e EMAIL_HOST_PASSWORD=userpass
-e EMAIL_PORT=25
-e GITLAB_URL=https://somegitlabinstallation.com
-e GITLAB_CLIENT_ID=xxxxx
-e GITLAB_CLIENT_SECRET=xxxxx
```

Sample Run:
```
docker run -it --rm -p 80:80 \
	-v /opt/taiga/postgresql:/var/lib/postgresql \
	-v /opt/taiga/rabbitmq:/var/lib/rabbitmq \
	-v /opt/taiga/media:/taiga-back/media \
	-e HOST_NAME=example.com \
	-e DOMAIN_NAME=example.com \
	-e SECURE=false starpost/taiga-all-in-one
```
