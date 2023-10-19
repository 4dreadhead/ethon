# frozen_string_literal: true

require "time"

require_relative "telegram_bot"

# A class for intercom
class Intercom
  attr_reader :logger, :redis

  # @param [Logger] logger
  # @param [Redis] redis
  def initialize(logger:, redis:)
    @logger = logger
    @redis = redis
  end

  # @param [Hash] message
  def webhook!(message)
    case message[:topic]
    when "ping" then ping message
    else
      other message
    end
  end

  # @param [Integer] chat_id
  # @return [Boolean]
  def listener_exists?(chat_id)
    redis.hexists listeners_cache_key, chat_id
  end

  # @param [Integer] chat_id
  # @return [Hash]
  def add_listener(chat_id)
    redis.hmset listeners_cache_key, chat_id, Time.now.utc.to_i
  end

  # @param [Integer] chat_id
  def remove_listener(chat_id)
    redis.hdel listeners_cache_key, [chat_id]
  end

  # @return [Array]
  def listeners
    redis.hgetall listeners_cache_key
  end

  private

  # @param [Hash] message
  def ping(message)
    telegram_bot.send_message message: message.dig(:data, :item, :message),
                              keyboard: :link
  end

  # @param [Hash] message
  def other(message)
    unless message.is_a? Hash
      logger.warn "A message is not a Hash: #{message.inspect}"
      return self
    end

    data = message.dig :data
    unless data.is_a? Hash
      logger.warn "A data is not a Hash: #{data.inspect}"
      return self
    end

    item = data.dig :item
    unless item.is_a? Hash
      logger.warn "An item is not a Hash: #{item.inspect}"
      return self
    end

    source = item.dig :source
    source ||= item.dig :conversation, :source
    author = {}
    author = source.dig :author if source.is_a? Hash
    message_parts = ["#{message[:topic]}"]
    message_parts << " от #{author[:name]} (#{author[:email]})" if author[:id]
    listeners.keys.each do |chat_id|
      telegram_bot.send_message message: message_parts.join
    end
  end

  def telegram_bot
    @telegram_bot ||= TelegramBot.new(logger:, redis:)
  end

  # @return [String]
  def listeners_cache_key
    [base_cache_key, :listeners].join ":"
  end

  # @return [String]
  def base_cache_key
    self.class.name
  end
end
