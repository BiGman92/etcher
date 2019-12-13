FROM balenalib/aarch64-debian-node:10-buster-build as builder

RUN apt-get update
RUN apt-get install python

WORKDIR /usr/src/app

ENV npm_config_disturl=https://electronjs.org/headers
ENV npm_config_runtime=electron
ENV npm_config_target=7.1.3

COPY src src
COPY binding.gyp npm-shrinkwrap.json package.json ./

RUN npm i

COPY assets assets
COPY lib lib
COPY scripts scripts
COPY typings typings
COPY tsconfig.json webpack.config.ts ./

RUN npm run webpack

FROM alexisresinio/aarch64-debian-bejs:latest
COPY --from=builder /usr/src/app/node_modules /usr/src/app/node_modules
COPY --from=builder /usr/src/app/generated /usr/src/app/generated
COPY --from=builder /usr/src/app/assets /usr/src/app/assets
COPY --from=builder /usr/src/app/build /usr/src/app/build
COPY --from=builder /usr/src/app/lib /usr/src/app/lib
COPY --from=builder /usr/src/app/package.json /usr/src/app/package.json

# TODO: remove once we have a screen
ENV VNC_PASSWORD=password

ENV ELECTRON_ENABLE_LOGGING=1

# Etcher configuration
COPY etcher-pro-config.json /root/.config/balena-etcher/config.json
