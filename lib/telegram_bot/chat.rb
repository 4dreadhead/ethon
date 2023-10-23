# frozen_string_literal: true

class TelegramBot
  # A class for a chat
  class Chat
    EMAIL_DOMAIN = "@tguser.com"

    attr_reader :created_at, :id, :email, :redis
    attr_accessor :phone_number, :first_name, :last_name

    class << self
      # @param [Integer] chat_id
      # @param [String] email
      # @param [Redis] redis
      # @return [Chat]
      def find_or_initialize(chat_id: nil, email: nil, redis:)
        id = chat_id
        id ||= email_to_id(email:, redis:) if email
        attributes = find_by_id(id:, redis:) if id
        attributes ||= {}
        default_attributes = {
          created_at: Time.now.utc.to_i,
          id:,
          phone_number: nil,
          first_name: nil,
          last_name: nil,
          email:,
          redis:
        }.each do |key, value|
          attributes[key] ||= value
        end
        new(**attributes)
      end

      # @param [Integer] id
      # @param [Redis] redis
      # @return [Hash]
      def find_by_id(id:, redis:)
        return {} unless id

        chat_str = redis.get cache_key(id)
        return {} unless chat_str

        JSON.parse chat_str, symbolize_names: true
      rescue => e
        {}
      end

      # @param [String] email
      # @param [Redis] redis
      # @return [Integer]
      def email_to_id(email:, redis:)
        id = redis.hget emails_with_id_cache_key, email
        id.to_i if id
      end

      # @param [String] email
      # @param [Integer] id
      # @param [Redis] redis
      # @return [Integer]
      def add_email_with_id(email:, id:, redis:)
        redis.hmset emails_with_id_cache_key, email, id.to_s
      end

      # @param [String] email
      # @param [Redis] redis
      def remove_email_with_id(email:, redis:)
        redis.hdel emails_with_id_cache_key, [email]
      end

      # @param [Redis] redis
      # @return [Array]
      def admin_ids(redis:)
        redis.hgetall(admins_cache_key).keys
      end

      # @param [Redis] redis
      # @return [Array]
      def add_admin(id:, redis:)
        redis.hmset admins_cache_key, id, "1"
      end

      # @param [String] email
      # @param [Redis] redis
      def remove_admin(id:, redis:)
        redis.hdel admins_cache_key, [id]
      end

      # @return [String]
      def admins_cache_key
        [base_cache_key, :admins].join ":"
      end

      # @return [String]
      def emails_with_id_cache_key
        [base_cache_key, :emails_with_id].join ":"
      end

      # @param [Integer] id
      # @return [String]
      def cache_key(id)
        [base_cache_key, :chat, id].join ":"
      end

      # @return [String]
      def base_cache_key
        name
      end
    end

    # @param [Integer] created_at
    # @param [Integer] id
    # @param [String] phone_number
    # @param [String] first_name
    # @param [String] last_name
    # @param [String] email
    # @param [Redis] redis
    def initialize(created_at:, id:, phone_number:, first_name:, last_name:, email:, redis:)
      raise "Id is required!" unless id

      @created_at = created_at
      @id = id
      @phone_number = phone_number
      @first_name = first_name
      @last_name = last_name
      @email = email
      @redis = redis
    end

    # @return [String]
    def name
      [first_name, last_name].compact.join " "
    end

    # @return [Boolean]
    def phone_shared?
      phone_number_valid?
    end

    def destroy
      redis.del cache_key
      self.class.remove_email_with_id(email:, redis:) if email

      self
    end

    # @return [Hash]
    def to_h
      {
        created_at:,
        id:,
        phone_number:,
        first_name:,
        last_name:,
        email:
      }
    end

    def save!
      set_email! unless email
      check_phone_number!

      self.class.add_email_with_id(email:, id:, redis:) if email
      redis.setex cache_key, CACHE_TTL, to_h.to_json
      self
    end

    def set_email!
      return unless phone_number

      @email = [phone_number, EMAIL_DOMAIN].join
    end

    private

    # @return [Boolean]
    def phone_number_valid?
      return false unless phone_number
      return false unless phone_number.is_a? String
      return false if phone_number.empty?

      true
    end

    def check_phone_number!
      phone_number_valid? || raise("Phone number is required!")
    end

    # @return [String]
    def cache_key
      @cache_key ||= [self.class.base_cache_key, :chat, id].join ":"
    end
  end
end
