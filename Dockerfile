# FROM node:15-slim as builder

## Install build toolchain, install node deps and compile native add-ons
# RUN apt-get update && \
#     apt-get install python3 make g++ -y
# RUN npm install fibers
# RUN chmod -R 777 ./node_modules/fibers ./node_modules/.bin

FROM node:15-slim AS base

EXPOSE 8080 9229 8888

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get upgrade -y && apt-get install -y procps iproute2 git dumb-init

RUN bash -c " \
    if [[ -n "$GID" && "$GID" != "1000" ]]; then \
      if [ -z "`getent group $GID`" ]; then \
        groupmod -g $GID node; \
      else \
        groupmod -n node-old node; \
        groupmod -n node `getent group $GID | cut -d: -f1`; \
        usermod -g $GID node; \
      fi \
    fi && \
    if [[ -n "$UID" && "$UID" != "1000" ]]; then \
      if [ -z "`getent passwd $UID`" ]; then \
        usermod -u $UID -g $GID node; \
      else \
        userdel node; \
        usermod -l node -g $GID -d /home/node -m `getent passwd $UID | cut -d: -f1`; \
      fi \
    fi \
    "

RUN apt-get install -y tzdata && \
    cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime && \
    echo "Europe/Brussels" >  /etc/timezone && \
    date && \
    apt-get remove --purge -y tzdata

RUN rm -rf /tmp/* && \
    rm -rf /var/cache/*

ENV DOCKERIZE_VERSION v0.6.1

RUN apt-get install -y wget
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
   && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
   && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz


# installed in apt
# ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.4/dumb-init_1.2.4_amd64 /usr/local/bin/dumb-init
# RUN chmod +x /usr/local/bin/dumb-init


ENV CHROME_ARGS="--no-sandbox --headless --disable-gpu --window-size=1920,1050 --disable-web-security --disable-translate --disable-extensions --disable-dev-shm-usage --hide-scrollbars --mute-audio --disable-setuid-sandbox --disable-infobars"

# Tell Puppeteer to skip installing Chrome.
# We'll be using the installed package instead.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# add `/app/node_modules/.bin` to $PATH
ENV PATH /home/node/.npm-global/bin:$PATH

ENV NPM_CONFIG_PREFIX /home/node/.npm-global
ENV NG_CLI_ANALYTICS ci
ENV NODE_OPTIONS --max-old-space-size=6144

#ENV TERM xterm-256color

RUN apt-get remove --purge -y wget

RUN apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y

USER node
RUN mkdir -p /home/node/app
WORKDIR /home/node/app

RUN id -u $USER
RUN id -g $USER

RUN npm config set prefix /home/node/ \
      npm config set cache /home/node/.npm \
      npm config set userconfig /home/node/.npmrc

FROM base AS dependencies

RUN npm i -g npm

USER root
RUN rm -rf /usr/local/lib/node_modules
RUN rm /usr/local/bin/npm /usr/local/bin/npx

USER node
# COPY --from=builder ./node_modules/fibers /home/node/.npm-global/lib/node_modules/fibers/
# COPY --from=builder ./node_modules/detect-libc /home/node/.npm-global/lib/node_modules/detect-libc/

# RUN ln -s ../lib/node_modules/detect-libc/bin/detect-libc.js /home/node/.npm-global/bin/detect-libc


ENTRYPOINT ["dumb-init"]
