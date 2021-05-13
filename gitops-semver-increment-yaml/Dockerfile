FROM node:16.1.0-alpine3.13

RUN wget https://github.com/mikefarah/yq/releases/download/v4.8.0/yq_linux_amd64.tar.gz -O - |\
  tar xz && mv yq_linux_amd64 /usr/bin/yq

COPY entrypoint.sh semver-increment.js /

ENTRYPOINT ["/entrypoint.sh"]