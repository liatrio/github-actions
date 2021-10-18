FROM alpine/git:v2.24.1

RUN apk --no-cache add curl
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]