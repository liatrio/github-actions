FROM node:14-alpine

WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .

RUN yarn install --production
COPY snow.js .
COPY index.js .
COPY actions actions

ENTRYPOINT ["node", "/usr/src/app/index.js"]
