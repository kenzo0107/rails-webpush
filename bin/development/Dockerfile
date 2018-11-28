FROM ruby:2.5.1-alpine
LABEL maintainer="kiyotaka.sasaya@medpeer.co.jp"

# dockerize用
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories

RUN apk add --no-cache --update \
    bash build-base mysql-client mysql-dev nodejs yarn dockerize \
    tzdata less file imagemagick chromium chromium-chromedriver
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ENV APP_PATH /usr/src/app
WORKDIR $APP_PATH

CMD ["docker/development/entrypoint.sh"]
