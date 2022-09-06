#!/bin/sh
[ -z "$SERVER_NAME" ]    && SERVER_NAME=example.com
[ -z "$MAX_FILESIZE" ]   && MAX_FILESIZE=512
[ -z "$MIN_FILEAGE" ]    && MIN_FILEAGE=10
[ -z "$MAX_FILEAGE" ]    && MAX_FILEAGE=180
[ -z "$UPLOAD_TIMEOUT" ] && UPLOAD_TIMEOUT=300
[ -z "$ID_LENGTH" ]      && ID_LENGTH=3
[ -z "$ADMIN_EMAIL" ]    && ADMIN_EMAIL="admin@example.com"
[ -z "$AUTO_FILE_EXT" ]  && AUTO_FILE_EXT=false

[ -n "$REVERSE_PROXY" ]  && sed -i "s|###RPROXY_GOES_HERE###|real_ip_header X-Forwarded-For; real_ip_recursive on; set_real_ip_from $REVERSE_PROXY;|" /etc/nginx/http.d/single_php_filehost.conf

sed -i 's/\(server_name\).*;/\1 '${SERVER_NAME}';/' /etc/nginx/http.d/single_php_filehost.conf

sed -i "s/\(const MAX_FILESIZE\)[^;]*/\1 = ${MAX_FILESIZE}/" /srv/single_php_filehost/index.php
sed -i "s/\(const MIN_FILEAGE\)[^;]*/\1 = ${MIN_FILEAGE}/" /srv/single_php_filehost/index.php
sed -i "s/\(const MAX_FILEAGE\)[^;]*/\1 = ${MAX_FILEAGE}/" /srv/single_php_filehost/index.php
sed -i "s/\(const UPLOAD_TIMEOUT\)[^;]*/\1 = ${UPLOAD_TIMEOUT}/" /srv/single_php_filehost/index.php
sed -i "s/\(const ID_LENGTH\)[^;]*/\1 = ${ID_LENGTH}/" /srv/single_php_filehost/index.php
sed -i "s/\(const ADMIN_EMAIL\)[^;]*/\1 = \'${ADMIN_EMAIL}\'/" /srv/single_php_filehost/index.php
sed -i "s/\(const AUTO_FILE_EXT\)[^;]*/\1 = ${AUTO_FILE_EXT}/" /srv/single_php_filehost/index.php
sed -i "s/\(const STORE_PATH\)[^;]*/\1 = '\/files\/'/" /srv/single_php_filehost/index.php

sed -i 's/\(upload_max_filesize\) *=.*/\1='${MAX_FILESIZE}'M/' /etc/php8/php.ini
sed -i 's/\(max_file_uploads\) *=.*/\1=1/' /etc/php8/php.ini
sed -i 's/\(post_max_size\) *=.*/\1='${MAX_FILESIZE}'M/' /etc/php8/php.ini
sed -i 's/\(max_input_time\) *=.*/\1='${UPLOAD_TIMEOUT}'/' /etc/php8/php.ini
sed -i 's/\(max_execution_time\) *=.*/\1='${UPLOAD_TIMEOUT}'/' /etc/php8/php.ini

sed -i 's/\(user\).*/\1=nginx/' /etc/php8/php-fpm.d/www.conf

sed -i "s/\(client_max_body_size\)[^;]*/\1 ${MAX_FILESIZE}m/" /etc/nginx/nginx.conf

mkdir -p /files
chown -R nginx:nobody /files
chmod -R u=rwX,g=,o= /files

exec /usr/bin/supervisord -c /etc/supervisord.conf
