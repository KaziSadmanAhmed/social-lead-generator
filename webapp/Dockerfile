# build stage

FROM node:12-alpine as build-stage

WORKDIR /app
COPY package.json .
COPY yarn.lock .

RUN yarn

COPY . .

RUN yarn build


# serve stage

FROM caddy:2-alpine as serve-stage

COPY --from=build-stage /app/dist /srv
COPY ./caddy/Caddyfile /etc/caddy/Caddyfile

EXPOSE 80
