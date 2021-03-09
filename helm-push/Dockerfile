FROM alpine/helm:3.1.2

RUN apk add --no-cache bash git curl jq

ENV XDG_DATA_HOME /root/.local/share
ENV HELM_HOME ${XDG_DATA_HOME}/helm
ENV HELM_S3_MODE 3

##RUN https://github.com/steven-sheehy/helm-s3/releases/download/v0.9.0/helm-s3_0.9.0_linux_amd64.tar.gz -o /tmp/helm-s3.tar.gz \
#    && mkdir -p ${HELM_HOME}/plugins/helm-s3 \
#    && tar xzf /tmp/helm-s3.tar.gz -C ${HELM_HOME}/plugins/helm-s3 \
#    && rm /tmp/helm-s3.tar.gz
RUN helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.10.0

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
