FROM ruby:3.2.2-bullseye

RUN apt-get update && \
    apt-get install -qq -y apt-utils build-essential libpq-dev wget chrpath libssl-dev --no-install-recommends && \
    mkdir /var/app
RUN echo "gem: --no-ri --no-rdoc" >> ~/.gemrc && \
    gem install bundler --no-document

VOLUME ["/var/app/vendor"]
WORKDIR /var/app
