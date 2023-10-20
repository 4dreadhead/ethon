FROM umputun/nginx-le:v1.4.2

COPY service.conf /etc/nginx/service.conf

HEALTHCHECK CMD curl -f http://localhost/healthcheck
