# frozen_string_literal: true

require_relative "strategies/base"
require_relative "strategies/share_phone"
require_relative "strategies/unknown"

class TelegramBot
  # A module for strategies
  module Strategies
    # @param [Bot] bot
    # @param [Hash] message
    # @param [Logger] logger
    # @param [Redis] redis
    def find(bot:, message:, logger:, redis:)
      text = message[:text]
      strategy = nil
      strategy = SharePhone unless text && bot.chat.phone_shared?
      strategy ||= Unknown
      strategy.new bot:, message:, logger:, redis:
    end

    module_function :find
  end
end
