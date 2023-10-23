# frozen_string_literal: true

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

    # @return [String]
    def server_url
      ENV.fetch "SERVER_URL"
    end

    # @param [String] email
    # @return [String]
    def chat_url(chat_id)
      [server_url, CHAT_PATH, "?uid=", chat_id].join
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
    when "conversation.admin.replied"
      conversation_admin_replied message
    when "conversation.user.replied", "conversation.user.created"
      conversation_user_replied message
    else
      logger.warn "An unforeseen topic: #{message[:topic].inspect}"
    end
  end

  private

  # @param [Hash] message
  def ping(message)
    the_message = message.dig :data, :item, :message
    telegram_bot.admin_ids.each do |chat_id|
      telegram_bot.send_message(message: the_message, chat_id:)
    end
  end

  # Create a new message from admin, send a notification to a client
  # @param [Hash] message
  def conversation_admin_replied(message)
    item = webhook_item! message
    author = webhook_author! item
    chat_id = TelegramBot::Chat.email_to_id(email: author[:email], redis:)
    telegram_bot.send_message(
      message: ["№", item[:id], ": ", "Вам ответил оператор!"].join,
      keyboard: :link_to_chat,
      chat_id:,
      url: self.class.chat_url(chat_id)
    )
  end

  # Create a new message from a client, send a notification to admins
  # @param [Hash] message
  def conversation_user_replied(message)
    item = webhook_item! message
    author = webhook_author! item
    telegram_bot.admin_ids.each do |chat_id|
      telegram_bot.send_message(
        message: ["№", item[:id], ": ", author[:name], " (", author[:email], ") написал!"].join,
        keyboard: :link_to_chat,
        chat_id: chat_id,
        url: conversation_url(item[:id])
    )
    end
  end

  # @param [Hash] item
  # @return [Hash]
  def webhook_author!(item)
    source = item.dig :source
    raise "A source is not a Hash: #{source.inspect}" unless source.is_a? Hash

    author = source.dig :author
    raise "An author is not a Hash: #{author.inspect}" unless author.is_a? Hash

    author
  end

  # @param [Hash] message
  # @return [Hash]
  def webhook_item!(message)
    raise "A message is not a Hash: #{message.inspect}" unless message.is_a? Hash

    item = message.dig :data, :item
    raise "An item is not a Hash: #{item.inspect}" unless item.is_a? Hash

    item
  end

  # @param [Integer] id
  # @return [String]
  def conversation_url(id)
    [APPS_URL, self.class.app_id, "/conversations/", id].join
  end

  def telegram_bot
    @telegram_bot ||= TelegramBot.new(logger:, redis:)
  end

  # @return [String]
  def base_cache_key
    self.class.name
  end
end
