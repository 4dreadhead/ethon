# frozen_string_literal: true

require "logger"

# A module for logging
module Logging
  def logger
    @logger ||= Logger.new(STDOUT, level: ENV["LOGLEVEL"] || Logger::WARN)
  end

  module_function :logger
end
