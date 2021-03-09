FROM alpine/helm:3.1.2

RUN apk add --no-cache bash git curl jq

ENV XDG_DATA_HOME /root/.local/share
ENV HELM_HOME ${XDG_DATA_HOME}/helm
ENV HELM_S3_MODE 3

RUN helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.10.0

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
