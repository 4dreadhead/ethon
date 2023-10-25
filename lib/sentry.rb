# frozen_string_literal: true

require "sentry-ruby"

require_relative "logging"

# https://docs.sentry.io/platforms/ruby/configuration/options/
Sentry.init do |config|
  config.environment = ENV.fetch "RAKE_ENV", "development"
  config.dsn = ENV["SENTRY_DSN"]
  config.enabled_environments = %w[production]
  config.logger = Logging.logger
  config.traces_sample_rate = 0.2
  config.background_worker_threads = 0
end
