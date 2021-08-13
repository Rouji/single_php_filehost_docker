example usage
```bash
docker build . -t single_php_filehost
docker run -d -p 8080:80 \
    -e SERVER_NAME=example.com \
    -e MAX_FILESIZE=10 \
    -e MIN_FILEAGE=1 \
    -e MAX_FILEAGE=10 \
    -e UPLOAD_TIMEOUT=60 \
    -e ADMIN_EMAIL=noreply@example.com \
    -v /path/to/files:/srv/single_php_filehost/files \
    single_php_filehost
```
