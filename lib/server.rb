# frozen_string_literal: true

require "sinatra"
require "json"

require_relative "cached"
require_relative "logging"
require_relative "intercom"

get "/healthcheck" do
  halt 204
end

get "/link" do
  send_file "templates/link.html"
end

post "/webhook/telegram" do
  logger.info "/webhook/telegram"
  request_body = JSON.parse request.body.read, symbolize_names: true rescue nil
  request_body = {} unless request_body.is_a? Hash
  logger.debug "request_body:"
  logger.debug request_body.to_json
  TelegramBot.new(logger:, redis:).webhook! request_body
rescue => error
  logger.error error.message
  logger.error error.backtrace
ensure
  halt 200
end

post "/webhook/intercom" do
  logger.info "/webhook/intercom"
  request_body = JSON.parse request.body.read, symbolize_names: true rescue nil
  request_body = {} unless request_body.is_a? Hash
  logger.debug "request_body:"
  logger.debug request_body.to_json
  Intercom.new(logger:, redis:).webhook! request_body
rescue => error
  logger.error error.message
  logger.error error.backtrace
ensure
  halt 200
end

helpers do
  def logger
    Logging.logger
  end

  def redis
    Cached.redis
  end
end
