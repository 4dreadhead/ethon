# frozen_string_literal: true

require_relative "telegram_api"
require_relative "telegram_bot/chat"
require_relative "telegram_bot/texts"
require_relative "telegram_bot/strategies"

# A class for Telegram bot
class TelegramBot
  STATE_INITIAL = "initial"
  STATE_TTL = 86400
  CACHE_TTL = 311_040_000 # 60 × 60 × 24 x 30 x 12 x 10

  attr_reader :logger, :chat, :redis

  # @param [Logger] logger
  # @param [Redis] redis
  def initialize(logger:, redis:)
    @logger = logger
    @redis = redis
  end

  # @param [Hash] body
  def webhook!(body)
    message = body[:message]
    message ||= body[:callback_query]
    Strategies.find(bot: self, message:, logger:, redis:).perform
  end

  # @param [String] message
  # @param [Symbol] keyboard
  def send_message(message:, keyboard: nil)
    telegram_api.send_message(
      chat_id: 813570115,
      reply_markup: build_reply_markup(kind: keyboard),
      text: message
    )
  end

  def state
    redis.get(state_cache_key) || STATE_INITIAL
  end

  # @param [String] new_state
  def state!(new_state)
    redis.setex state_cache_key, STATE_TTL, new_state
  end

  # @return [String]
  def chat_cache_key
    [base_cache_key, chat.id].join ":"
  end

  def intercom
    @intercom ||= Intercom.new(logger:, redis:)
  end

  private

  def telegram_api
    @api ||= TelegramApi.new(logger:)
  end

  # @param [Symbol] kind
  # @return [Hash]
  def build_reply_markup(kind:)
    case kind
    when :share_phone
      {
        keyboard: [
          [
            text: "Поделиться номером телефона",
            request_contact: true
          ]
        ],
        resize_keyboard: true
      }
    else
      # https://core.telegram.org/bots/api#replykeyboardremove
      { remove_keyboard: true }
    end
  end

  # @return [String]
  def state_cache_key
    [chat_cache_key, :state].join ":"
  end

  # @return [String]
  def base_cache_key
    self.class.name
  end
end
