ARG NODE_TAG=16-alpine
FROM node:${NODE_TAG} as builder

WORKDIR /action

COPY entrypoint.sh package.json yarn.lock ./

RUN yarn install --production

###

FROM node:${NODE_TAG}
LABEL org.opencontainers.image.source=https://github.com/liatrio/github-actions

WORKDIR /action

# Installing Git from the edge branch to get latest available version
RUN apk add git --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
RUN apk add --no-cache bash openssh curl

ENV HELM_VERSION 3.8.0
RUN curl -f -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -zx && \
  chmod +x linux-amd64/helm && \
  mv linux-amd64/helm /usr/bin && \
  rm -rf linux-amd64 && \
  helm version

COPY --from=builder /action .
RUN git config --global --add safe.directory $GITHUB_WORKSPACE
ENTRYPOINT ["/action/entrypoint.sh"]
