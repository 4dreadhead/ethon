FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY conf.d /etc/nginx/conf.d
COPY nginx.conf /etc/nginx/nginx.conf

HEALTHCHECK CMD curl -f http://localhost/healthcheck
