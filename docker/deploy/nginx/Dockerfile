FROM nginx:1.15.0-alpine

# TZ JST
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN rm -f /etc/nginx/conf.d/*
COPY ./docker/deploy/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/deploy/nginx/default.conf /etc/nginx/conf.d/default.conf

CMD ["/usr/sbin/nginx", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf"]
