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
    -e EXTERNAL_HOOK=/hook.sh \
    -v /path/to/files:/files \
    -v /path/to/hook.sh:/hook.sh \
    single_php_filehost
```
