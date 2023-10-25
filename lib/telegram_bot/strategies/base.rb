# frozen_string_literal: true

class TelegramBot
  module Strategies
    # A base class
    class Base
      attr_reader :bot, :message, :logger, :redis

      class << self
        def states
          []
        end

        # @return [String]
        def base_cache_key
          name
        end
      end

      # @param [TelegramApi::Bot] bot
      # @param [Hash] message
      # @param [Logger] logger
      # @param [Redis] redis
      def initialize(bot:, message:, logger:, redis:)
        @bot = bot
        @message = message
        @logger = logger
        @redis = redis
      end

      def perform
        raise NotImplementedError
      end

      private

      # @param [String] phone
      # @return [String]
      def look_for_phone(phone: nil)
        str = phone || message[:text]
        match_data = %r(^\+?(7[0-9]{10})$).match str
        match_data[1] if match_data
      end

      # @return [String]
      def base_cache_key
        self.class.base_cache_key
      end
    end
  end
end
