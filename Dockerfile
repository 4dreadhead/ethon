FROM ruby:3.2.2-bullseye

ARG PORT
ENV PORT $PORT

RUN apt-get install -qq -y curl

RUN mkdir /var/app
RUN echo "gem: --no-ri --no-rdoc" >> ~/.gemrc && \
    gem install bundler --no-document && \
    bundle config set --local without "production" && \
    bundle config set --local path "vendor" && \
    bundle config --global frozen 1

WORKDIR /var/app

COPY config config
COPY lib lib
COPY tmp tmp
COPY config.ru Gemfile Gemfile.lock init.rb ./

HEALTHCHECK --start-period=5m --timeout=30s CMD curl -f http://127.0.0.1:$PORT/healthcheck
VOLUME ["/var/app/tmp/pids", "/var/app/vendor"]
ENTRYPOINT ["ruby", "/var/app/init.rb"]
