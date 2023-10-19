# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "puma", "~> 6.4"
gem "sinatra", "~> 3.0"
gem "logger", "~> 1.5"
gem "json", "~> 2.6"
gem "faraday", "~> 1.10"
gem "faraday_middleware", "~> 1.2"
gem "redis", "~> 5.0"

group :test do
  gem "rubocop"
  gem "rubocop-performance"
end
