FROM python:3.5

RUN apt-get update && apt-get install -y \
	python3 \
	python3-pip \
	python3-dev \
	virtualenvwrapper \
	libxml2-dev \
	libxslt-dev \
	rabbitmq-server \
	redis-server \
	postgresql-9.4 \
	postgresql-contrib-9.4 \
	postgresql-doc-9.4 \
	postgresql-server-dev-9.4 \
	nodejs \
	npm \
	unzip \
	gettext \
	nginx \
&& rm -rf /var/lib/apt/lists/*

# ===== taiga backend
RUN wget -O /taiga-back.zip \
	https://github.com/taigaio/taiga-back/archive/stable.zip
RUN unzip /taiga-back.zip -d /
RUN mv /taiga-back-stable /taiga-back

WORKDIR /taiga-back
RUN virtualenv -p /usr/local/bin/python3.5 taiga
RUN pip install -r requirements.txt

COPY taiga-back/* /taiga-back/settings/

RUN python manage.py compilemessages
RUN python manage.py collectstatic --noinput


# ===== taiga frontend
RUN wget -O /taiga-front-dist.zip \
	https://github.com/taigaio/taiga-front-dist/archive/stable.zip
RUN unzip /taiga-front-dist.zip -d /
RUN mv /taiga-front-dist-stable /taiga-front-dist

WORKDIR /taiga-front-dist

COPY taiga-front/* /taiga-front-dist/dist/


# ===== taiga events
RUN git clone https://github.com/taigaio/taiga-events.git /taiga-events
WORKDIR /taiga-events
RUN npm cache clean -f
RUN npm install -g n
RUN n stable
RUN npm install -g coffee-script
RUN npm install

COPY taiga-events/* /taiga-events/

# ===== nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# ===== Cleanup
RUN rm -rf /taiga-front-dist.zip /taiga-back.zip

# ===== Helper Scripts
RUN mkdir -p /scripts
COPY scripts/* /scripts/

WORKDIR /scripts

EXPOSE 80

VOLUME /var/lib/postgresql
VOLUME /var/lib/rabbitmq

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD [ "./forego", "start" ]

