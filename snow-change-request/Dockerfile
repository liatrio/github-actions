FROM node:14-alpine

WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .

RUN yarn install --production
COPY index.js .
ENTRYPOINT ["node", "index.js"]
