# frozen_string_literal: true

require "sentry-ruby"

require_relative "logging"

Sentry.configure do |config|
  config.current_environment = ENV.fetch "RAKE_ENV", "development"
  config.dsn = ENV["SENTRY_DSN"]
  config.environments = %w[production]
  config.logger = Logging.logger
end
