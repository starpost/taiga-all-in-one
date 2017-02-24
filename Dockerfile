FROM python:3.5

RUN git clone https://github.com/taigaio/taiga-back.git taiga-back
WORKDIR taiga-back
RUN git checkout stable

RUN apt-get update && apt-get install -y \
	python3 \
	python3-pip \
	python-dev \
	python3-dev \
	python-pip \
	virtualenvwrapper \
	libxml2-dev \
	libxslt-dev \
	rabbitmq-server \
	redis-server \
	nodejs \
	nodejs-legacy \
	npm \
	nginx

RUN virtualenv -p /usr/local/bin/python3.5 taiga
RUN pip install -r requirements.txt

RUN apt-get install -y \
	postgresql-9.4 \
	postgresql-contrib-9.4 \
	postgresql-doc-9.4 \
	postgresql-server-dev-9.4

COPY taiga-back/* /taiga-back/settings/

# ===== taiga frontend
RUN apt-get install -y \
	unzip
RUN wget -O /taiga-front-dist.zip \
	https://github.com/taigaio/taiga-front-dist/archive/stable.zip
RUN unzip /taiga-front-dist.zip -d /
RUN mv /taiga-front-dist-stable /taiga-front-dist

#RUN git clone https://github.com/taigaio/taiga-front-dist.git /taiga-front-dist
WORKDIR /taiga-front-dist
#RUN git checkout stable

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


RUN mkdir -p /scripts
COPY scripts/* /scripts/

WORKDIR /scripts

EXPOSE 80

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD [ "./forego", "start" ]

