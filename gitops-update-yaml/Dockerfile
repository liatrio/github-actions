FROM alpine:3.13.5

RUN apk add yq --no-cache 

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]