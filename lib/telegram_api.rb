# frozen_string_literal: true

require "faraday"
require "faraday_middleware"

# A class for Telegram api
class TelegramApi
  class NotFoundError < StandardError; end

  API_BOT_BASE_URL = "https://api.telegram.org/bot"

  attr_reader :logger

  # @param [Logger] logger
  def initialize(logger:)
    @logger = logger
  end

  # https://core.telegram.org/bots/api#sendmessage
  # @param [Hash] message
  def send_message(chat_id:, reply_markup:, text:)
    message = {
      chat_id:,
      reply_markup:,
      text:
    }
    logger.debug "#{self.class.name}#send_message:"
    logger.debug(message)
    resp = connection.post request_url("sendMessage") do |req|
      req.body = message.to_json
    end
    validation_response!(resp).body
  end

  # https://core.telegram.org/bots/api#setwebhook
  def set_webhook(url)
    resp = connection.post request_url("setWebhook") do |req|
      req.body = { url: url }.to_json
    end
    validation_response!(resp).body
  end

  private

  # @param [Faraday::Response] response
  # @return [Faraday::Response]
  def validation_response!(response)
    logger.debug "[Telegram] - status: #{response.status}, body: #{response.body}"
    return response if (200..201).include? response.status
    return response if response.body["ok"]

    case response.body["error_code"]
    when 404
      raise NotFoundError, response.body["description"]
    else
      raise StandardError, response.body["description"]
    end
  end

  # @return [String]
  def telegram_base_url
    @telegram_base_url = [
      API_BOT_BASE_URL,
      ENV.fetch("TELEGRAM_TOKEN")
    ].join
  end

  # @param [String] path
  # @return [String]
  def request_url(path)
    [telegram_base_url, path].join "/"
  end

  def connection
    @connection = Faraday.new do |builder|
      builder.response :json, content_type: /\bjson$/
      builder.adapter Faraday.default_adapter
      builder.headers["Content-Type"] = "application/json"
      builder.response :logger, logger
    end
  end
end
