FROM alpine:3.19

ARG BRANCH=master

USER root
COPY entry.sh /entry.sh
RUN apk add git nginx php83-cli php83-fpm php83-fileinfo php83-ctype supervisor \
 && git clone -b $BRANCH --single-branch https://github.com/Rouji/single_php_filehost.git /srv/single_php_filehost \
 && mkdir /files \
 && chown -R nginx:nobody /srv/single_php_filehost && chmod -R u=rwX,g=,o= /srv/single_php_filehost \
 && chown -R nginx:nobody /files && chmod -R u=rwX,g=,o= /files \
 && rm /etc/nginx/http.d/default.conf \
 && echo -e "#!/bin/sh\n/usr/bin/php83 /srv/single_php_filehost/index.php purge" > /etc/periodic/daily/purge && chmod u+x /etc/periodic/daily/purge\
 && chmod u+x /entry.sh \
 && apk del git && rm -rf /var/cache/apk/*

COPY vhost.conf /etc/nginx/http.d/single_php_filehost.conf
COPY supervisord.conf /etc/supervisord.conf

VOLUME /files
EXPOSE 80

ENTRYPOINT ["/entry.sh"]
