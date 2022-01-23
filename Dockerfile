FROM alpine:3.14

USER root
COPY entry.sh /entry.sh
RUN apk add git nginx php8-fpm php8-fileinfo supervisor \
 && git clone https://github.com/Rouji/single_php_filehost.git /srv/single_php_filehost \
 && cd /srv/single_php_filehost && git reset --hard 5747e1dbd776bb6c2fec63488487543f3950a1e0 \
 && mkdir /srv/single_php_filehost/files \
 && chown -R nginx:nobody /srv/single_php_filehost && chmod -R u=rwX,g=,o= /srv/single_php_filehost \
 && rm /etc/nginx/http.d/default.conf \
 && chmod o+x /entry.sh

COPY vhost.conf /etc/nginx/http.d/single_php_filehost.conf
COPY supervisord.conf /etc/supervisord.conf

VOLUME /srv/single_php_filehost/files
EXPOSE 80

ENTRYPOINT ["/entry.sh"]
