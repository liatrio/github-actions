FROM alpine:3.13.5

RUN wget https://github.com/mikefarah/yq/releases/download/v4.8.0/yq_linux_amd64.tar.gz -O - |\
  tar xz && mv yq_linux_amd64 /usr/bin/yq

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]