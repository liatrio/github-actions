ARG NODE_TAG=14-alpine
FROM node:${NODE_TAG} as builder
WORKDIR /action
COPY package.json yarn.lock index.js ./
RUN yarn install --production

###

FROM node:${NODE_TAG}
LABEL org.opencontainers.image.source=https://github.com/liatrio/github-actions
WORKDIR /action
COPY --from=builder /action .
ENTRYPOINT ["node", "index.js"]
