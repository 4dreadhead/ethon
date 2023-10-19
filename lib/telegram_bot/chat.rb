# frozen_string_literal: true

class TelegramBot
  # A class for a chat
  class Chat
    attr_reader :id, :phone_number, :redis

    class << self
      # @param [Integer] chat_id
      # @param [Redis] redis
      # @return [Chat]
      def find_or_initialize(chat_id:, redis:)
        chat_str = redis.get cache_key(chat_id)
        hash = JSON.parse chat_str, symbolize_names: true if chat_str
        hash ||= { id: chat_id, phone_number: nil }
        new id: hash[:id],
            phone_number: hash[:phone_number],
            redis:
      end

      # @param [Integer] chat_id
      # @return [String]
      def cache_key(chat_id)
        [base_cache_key, :chat, chat_id].join ":"
      end

      # @return [String]
      def base_cache_key
        name
      end
    end

    # @param [Integer] id
    # @param [String] phone_number
    # @param [Redis] redis
    def initialize(id:, phone_number:, redis:)
      @id = id
      @phone_number = phone_number
      @redis = redis
    end

    # @return [Boolean]
    def phone_shared?
      return false unless phone_number
      return false unless phone_number.is_a? String
      return false if phone_number.empty?

      true
    end

    # @param [String] phone_number
    def phone_number!(phone_number)
      number = phone_number.to_s.strip
      raise "phone_number is required!" if number.empty?

      @phone_number = number
      save!
    end

    def destroy!
      redis.del cache_key
      self
    end

    # @return [Hash]
    def to_h
      {
        id: id,
        phone_number: phone_number
      }
    end

    private

    def save!
      redis.setex cache_key, CACHE_TTL, to_h.to_json
      self
    end

    def check_id!
      raise "Id is required!" unless id
    end

    # @return [String]
    def cache_key
      check_id!

      @cache_key ||= [self.class.base_cache_key, :chat, id].join ":"
    end
  end
end
