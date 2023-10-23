# frozen_string_literal: true

require "time"

require_relative "telegram_bot"

# A class for intercom
class Intercom
  CHAT_PATH = "/chat"
  APPS_URL = "https://app.intercom.com/a/apps/"

  attr_reader :logger, :redis

  class << self
    def app_id
      ENV.fetch "INTERCOM_APP_ID"
    end
  end

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
    when "conversation.admin.replied" then conversation_admin_replied message
    when "conversation.user.replied"  then conversation_user_replied message
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
    the_message = message.dig :data, :item, :message
    telegram_bot.admin_ids.each do |chat_id|
      telegram_bot.send_message(message: the_message, chat_id:)
    end
  end

  # A webhook about message from an admin, send a notification to a client
  # @param [Hash] message
  def conversation_admin_replied(message)
    unless message.is_a? Hash
      logger.warn "A message is not a Hash: #{message.inspect}"
      return self
    end

    item = message.dig :data, :item
    unless item.is_a? Hash
      logger.warn "An item is not a Hash: #{item.inspect}"
      return self
    end

    source = item.dig :source
    unless source.is_a? Hash
      logger.warn "A source is not a Hash: #{source.inspect}"
      return self
    end

    author = source.dig :author
    unless author.is_a? Hash
      logger.warn "An author is not a Hash: #{author.inspect}"
      return self
    end

    chat = telegram_bot.init_chat! email: author[:email]
    telegram_bot.send_message(
      message: ["№", item[:id], ": ", "Вам ответил оператор!"].join,
      keyboard: :link_to_chat,
      url: chat_url(chat.id)
    )
  end

  # A webhook about message from a client, send a notification to admins
  # @param [Hash] message
  def conversation_user_replied(message)
    unless message.is_a? Hash
      logger.warn "A message is not a Hash: #{message.inspect}"
      return self
    end

    item = message.dig :data, :item
    unless item.is_a? Hash
      logger.warn "An item is not a Hash: #{item.inspect}"
      return self
    end

    source = item.dig :source
    unless source.is_a? Hash
      logger.warn "A source is not a Hash: #{source.inspect}"
      return self
    end

    author = source.dig :author
    unless author.is_a? Hash
      logger.warn "An author is not a Hash: #{author.inspect}"
      return self
    end

    telegram_bot.admin_ids.each do |chat_id|
      telegram_bot.send_message(
        message: ["№", item[:id], ": ", author[:name], " (", author[:email], ") написал!"].join,
        keyboard: :link_to_chat,
        chat_id: chat_id,
        url: conversation_url(item[:id])
    )
    end
  end

  # @param [Integer] id
  # @return [String]
  def conversation_url(id)
    [APPS_URL, self.class.app_id, "/conversations/", id].join
  end

  # @param [String] email
  # @return [String]
  def chat_url(chat_id)
    [server_url, CHAT_PATH, "?uid=", chat_id].join
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
    telegram_bot.send_message(
      message: message_parts.join,
      email: author[:email]
    )
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

  # @return [String]
  def server_url
    @server_url ||= ENV.fetch "SERVER_URL"
  end
end
