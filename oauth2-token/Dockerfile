FROM curlimages/curl:7.77.0

USER root
RUN apk --no-cache add jq bash
USER curl_user

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
