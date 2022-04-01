ARG NODE_TAG=16-alpine
FROM node:${NODE_TAG} as builder
WORKDIR /action
COPY package.json yarn.lock ./
RUN yarn install --production
COPY index.js ./
COPY tests/ ./tests

###

FROM node:${NODE_TAG}
LABEL org.opencontainers.image.source=https://github.com/liatrio/github-actions
WORKDIR /action
COPY --from=builder /action .
ENTRYPOINT ["node", "/action/index.js"]
