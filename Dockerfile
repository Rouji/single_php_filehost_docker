FROM alpine:3.14

USER root
RUN apk add git nginx php8-fpm php8-fileinfo supervisor
RUN git clone https://github.com/Rouji/single_php_filehost.git /srv/single_php_filehost
RUN cd /srv/single_php_filehost; git reset --hard 5747e1dbd776bb6c2fec63488487543f3950a1e0
RUN mkdir /srv/single_php_filehost/files
RUN chown -R nginx:nobody /srv/single_php_filehost
RUN chmod -R u=rwX,g=,o= /srv/single_php_filehost

RUN rm /etc/nginx/http.d/default.conf
COPY vhost.conf /etc/nginx/http.d/single_php_filehost.conf
COPY supervisord.conf /etc/supervisord.conf
COPY entry.sh /entry.sh
RUN chmod o+x /entry.sh

ENTRYPOINT ["/entry.sh"]
