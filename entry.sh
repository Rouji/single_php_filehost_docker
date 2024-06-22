#!/bin/sh
[ -z "$SERVER_NAME" ]    && SERVER_NAME=example.com
[ -z "$MAX_FILESIZE" ]   && MAX_FILESIZE=512
[ -z "$MIN_FILEAGE" ]    && MIN_FILEAGE=10
[ -z "$MAX_FILEAGE" ]    && MAX_FILEAGE=180
[ -z "$UPLOAD_TIMEOUT" ] && UPLOAD_TIMEOUT=300
[ -z "$MIN_ID_LENGTH" ]  && MIN_ID_LENGTH=3
[ -z "$MAX_ID_LENGTH" ]  && MAX_ID_LENGTH=24
[ -z "$ADMIN_EMAIL" ]    && ADMIN_EMAIL="admin@example.com"
[ -z "$AUTO_FILE_EXT" ]  && AUTO_FILE_EXT=false

[ -n "$REVERSE_PROXY" ]  && sed -i "s|###RPROXY_GOES_HERE###|real_ip_header X-Forwarded-For; real_ip_recursive on; set_real_ip_from $REVERSE_PROXY;|" /etc/nginx/http.d/single_php_filehost.conf
[ -n "$FORCE_HTTPS" ]  && sed -i "s/###HTTPS_GOES_HERE###/fastcgi_param HTTPS 'on';/" /etc/nginx/http.d/single_php_filehost.conf

sed -i 's/\(server_name\).*;/\1 '${SERVER_NAME}';/' /etc/nginx/http.d/single_php_filehost.conf

sed -i "s/\(const MAX_FILESIZE\)[^;]*/\1 = ${MAX_FILESIZE}/" /srv/single_php_filehost/index.php
sed -i "s/\(const MIN_FILEAGE\)[^;]*/\1 = ${MIN_FILEAGE}/" /srv/single_php_filehost/index.php
sed -i "s/\(const MAX_FILEAGE\)[^;]*/\1 = ${MAX_FILEAGE}/" /srv/single_php_filehost/index.php
sed -i "s/\(const UPLOAD_TIMEOUT\)[^;]*/\1 = ${UPLOAD_TIMEOUT}/" /srv/single_php_filehost/index.php
sed -i "s/\(const MIN_ID_LENGTH\)[^;]*/\1 = ${MIN_ID_LENGTH}/" /srv/single_php_filehost/index.php
sed -i "s/\(const MAX_ID_LENGTH\)[^;]*/\1 = ${MAX_ID_LENGTH}/" /srv/single_php_filehost/index.php
sed -i "s/\(const ADMIN_EMAIL\)[^;]*/\1 = \'${ADMIN_EMAIL}\'/" /srv/single_php_filehost/index.php
sed -i "s/\(const AUTO_FILE_EXT\)[^;]*/\1 = ${AUTO_FILE_EXT}/" /srv/single_php_filehost/index.php
sed -i "s/\(const STORE_PATH\)[^;]*/\1 = '\/files\/'/" /srv/single_php_filehost/index.php
[ -n "$LOG_PATH" ] && sed -i "s|\(const LOG_PATH\)[^;]*|\1 = '${LOG_PATH}'|" /srv/single_php_filehost/index.php
[ -n "$EXTERNAL_HOOK" ] && sed -i "s|\(const EXTERNAL_HOOK\)[^;]*|\1 = '${EXTERNAL_HOOK}'|" /srv/single_php_filehost/index.php

sed -i 's/\(upload_max_filesize\) *=.*/\1='${MAX_FILESIZE}'M/' /etc/php83/php.ini
sed -i 's/\(max_file_uploads\) *=.*/\1=1/' /etc/php83/php.ini
sed -i 's/\(post_max_size\) *=.*/\1='${MAX_FILESIZE}'M/' /etc/php83/php.ini
sed -i 's/\(max_input_time\) *=.*/\1='${UPLOAD_TIMEOUT}'/' /etc/php83/php.ini
sed -i 's/\(max_execution_time\) *=.*/\1='${UPLOAD_TIMEOUT}'/' /etc/php83/php.ini

sed -i 's/\(user\).*/\1=nginx/' /etc/php83/php-fpm.d/www.conf

sed -i "s/\(client_max_body_size\)[^;]*/\1 ${MAX_FILESIZE}m/" /etc/nginx/nginx.conf

mkdir -p /files
chown -R nginx:nobody /files
chmod -R u=rwX,g=,o= /files
[ -n "$LOG_PATH" ] && touch "$LOG_PATH" && chown nginx:nobody "$LOG_PATH" && chmod u=rwX,g=,o= "$LOG_PATH"

exec /usr/bin/supervisord -c /etc/supervisord.conf
