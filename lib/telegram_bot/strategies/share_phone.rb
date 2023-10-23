# frozen_string_literal: true

class TelegramBot
  module Strategies
    # A class for sharing of a phone
    class SharePhone < Base
      def perform
        contact = message[:contact]
        phone_number = look_for_phone phone: contact[:phone_number] if contact.is_a? Hash
        unless phone_number.is_a? String
          bot.send_message message: Texts.build(:share_phone_number),
                           keyboard: :share_phone
          return self
        end

        unless self_contact? contact
          bot.send_message message: Texts.build(:share_phone_number_your),
                           keyboard: :share_phone
          return self
        end

        bot.chat.phone_number = phone_number
        bot.chat.first_name = contact[:first_name]
        bot.chat.last_name = contact[:last_name]
        bot.chat.save!
        bot.send_message message: Texts.build(:successfully),
                         entities: Texts.entities_for(
                           :successfully,
                           url: Intercom.chat_url(bot.chat.id)
                         )
        self
      end

      private

      # @param [Hash] contact
      # @return [Boolean]
      def self_contact?(contact)
        contact[:user_id].eql? bot.chat.id
      end
    end
  end
end
