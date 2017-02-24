Container Configuration
=======================

## Environment Variable Setup

```
-e HOST_NAME=example.com:8888
-e DOMAIN_NAME=example.com
-e SECURE=false
```

Sample Run:
```
docker run -it --rm -p80:80 \
	-v /opt/taiga/postgresql:/var/lib/postgresql \
	-v /opt/taiga/rabbitmq:/var/lib/rabbitmq \
	-e HOST_NAME=example.com \
	-e DOMAIN_NAME=example.com \
	-e SECURE=false <image_name>
```
