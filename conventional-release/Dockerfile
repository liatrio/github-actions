ARG NODE_TAG=14-alpine
FROM node:${NODE_TAG} as builder
WORKDIR /action
COPY entrypoint.sh package.json yarn.lock ./
RUN yarn install --production

###

FROM node:${NODE_TAG}
WORKDIR /action
RUN apk add --no-cache git bash
COPY --from=builder /action .
ENTRYPOINT ["/action/entrypoint.sh"]
