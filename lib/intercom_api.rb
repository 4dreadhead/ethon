# frozen_string_literal: true

require "faraday"
require "faraday_middleware"

# A class for intercom api
class IntercomApi
  BASE_URL = "https://api.intercom.io/"

  attr_reader :logger

  # @param [Logger] logger
  def initialize(logger:)
    @logger = logger
  end

  # https://developers.intercom.com/docs/references/rest-api/api.intercom.io/Conversations/listConversations/
  # @return [Hash]
  def conversations
    resp = connection.get request_url("conversations")
    validation_response!(resp).body
  end

  private

  # @param [Faraday::Response] response
  # @return [Faraday::Response]
  def validation_response!(response)
    logger.debug "#{self.class.name} status: #{response.status}, body: #{response.body}"
    return response if (200..201).include? response.status

    raise response.body.to_json
  end

  # @param [String] path
  # @return [String]
  def request_url(path)
    [BASE_URL, path].join "/"
  end

  # @return [String]
  def access_token
    ENV.fetch "INTERCOM_ACCESS_TOKEN"
  end

  def connection
    @connection = Faraday.new do |builder|
      builder.response :json, content_type: /\bjson$/
      builder.adapter Faraday.default_adapter
      builder.headers["Accept"] = "application/json"
      builder.headers["Content-Type"] = "application/json"
      builder.headers["Authorization"] = ["Bearer", access_token].join " "
      builder.response :logger, logger
    end
  end
end
