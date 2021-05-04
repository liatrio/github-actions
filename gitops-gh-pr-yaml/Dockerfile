FROM alpine:3.13.5

RUN apk add yq github-cli --no-cache 

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]