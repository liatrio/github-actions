FROM alpine:3.14.2

RUN apk add github-cli --no-cache 

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]