# frozen_string_literal: true

require "sinatra"
require "json"
require "erb"

require_relative "cached"
require_relative "logging"
require_relative "sentry"
require_relative "intercom"

get "/healthcheck" do
  halt 204
end

get Intercom::CHAT_PATH do
  chat_id = request.params["uid"]
  logger.debug [Intercom::CHAT_PATH, " chat_id: ", chat_id].join
  return halt 404 unless chat_id

  chat = TelegramBot::Chat.find_or_initialize(chat_id:, redis:)
  unless chat.phone_shared?
    status 400
    return "Неправильная ссылка."
  end

  return ERB.new(File.read("templates/intercom-chat.erb")).result_with_hash(
    name: chat.name,
    email: chat.email,
    created_at: chat.created_at,
    app_id: Intercom.app_id,
    api_base: "https://api-iam.intercom.io"
  )
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
  Sentry.capture_exception error
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
  Sentry.capture_exception error
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
