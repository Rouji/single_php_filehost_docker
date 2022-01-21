#!/bin/sh
[ -z "$SERVER_NAME" ]    && SERVER_NAME=example.com
[ -z "$MAX_FILESIZE" ]   && MAX_FILESIZE=512
[ -z "$MIN_FILEAGE" ]    && MIN_FILEAGE=10
[ -z "$MAX_FILEAGE" ]    && MAX_FILEAGE=180
[ -z "$UPLOAD_TIMEOUT" ] && UPLOAD_TIMEOUT=300
[ -z "$ID_LENGTH" ]      && ID_LENGTH=3
[ -z "$ADMIN_EMAIL" ]    && ADMIN_EMAIL="admin@example.com"
[ -z "$AUTO_FILE_EXT" ] && AUTO_FILE_EXT=false

sed -i 's/\(server_name\).*;/\1 '${SERVER_NAME}';/' /etc/nginx/http.d/single_php_filehost.conf

sed -i "4,18 s/\(MAX_FILESIZE\)[^;]*/\1 = ${MAX_FILESIZE}/" /srv/single_php_filehost/index.php
sed -i "4,18 s/\(MIN_FILEAGE\)[^;]*/\1 = ${MIN_FILEAGE}/" /srv/single_php_filehost/index.php
sed -i "4,18 s/\(MAX_FILEAGE\)[^;]*/\1 = ${MAX_FILEAGE}/" /srv/single_php_filehost/index.php
sed -i "4,18 s/\(UPLOAD_TIMEOUT\)[^;]*/\1 = ${UPLOAD_TIMEOUT}/" /srv/single_php_filehost/index.php
sed -i "4,18 s/\(ID_LENGTH\)[^;]*/\1 = ${ID_LENGTH}/" /srv/single_php_filehost/index.php
sed -i "4,18 s/\(ADMIN_EMAIL\)[^;]*/\1 = \'${ADMIN_EMAIL}\'/" /srv/single_php_filehost/index.php
sed -i "4,18 s/\(AUTO_FILE_EXT\)[^;]*/\1 = ${AUTO_FILE_EXT}/" /srv/single_php_filehost/index.php

sed -i 's/\(upload_max_filesize\) *=.*/\1='${MAX_FILESIZE}'M/' /etc/php8/php.ini
sed -i 's/\(max_file_uploads\) *=.*/\1=1/' /etc/php8/php.ini
sed -i 's/\(post_max_size\) *=.*/\1='${MAX_FILESIZE}'M/' /etc/php8/php.ini
sed -i 's/\(max_input_time\) *=.*/\1='${UPLOAD_TIMEOUT}'/' /etc/php8/php.ini
sed -i 's/\(max_execution_time\) *=.*/\1='${UPLOAD_TIMEOUT}'/' /etc/php8/php.ini

sed -i 's/\(user\).*/\1=nginx/' /etc/php8/php-fpm.d/www.conf

sed -i "s/\(client_max_body_size\)[^;]*/\1 ${MAX_FILESIZE}m/" /etc/nginx/nginx.conf

exec /usr/bin/supervisord -c /etc/supervisord.conf
