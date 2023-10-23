# frozen_string_literal: true

require "sentry-ruby"

require_relative "logging"

Sentry.init do |config|
  config.environment = ENV.fetch "RAKE_ENV", "development"
  config.dsn = ENV["SENTRY_DSN"]
  config.enabled_environments = %w[production]
  config.logger = Logging.logger
end
