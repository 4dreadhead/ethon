# frozen_string_literal: true

require "sinatra"
require "json"

require_relative "logging"

get "/healthcheck" do
  halt 204
end

post "/webhook/intercom" do
  logger.info "/webhook/intercom"

  request_body = JSON.parse request.body.read, symbolize_names: true rescue nil
  request_body = {} unless request_body.is_a? Hash
  logger.debug "request_body:"
  logger.debug request_body.to_json

  halt 200
end

helpers do
  def logger
    Logging.logger
  end
end
