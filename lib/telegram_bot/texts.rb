# frozen_string_literal: true

class TelegramBot
  # A class for texts
  class Texts
    DICTIONARY = {
      share_phone_number: "Поделитесь номером телефона",
      share_phone_number_your: "Поделитесь своим номером телефона",
      do_not_understand: "Не понимаю ):",
      successfully: "Это успех!"
    }.freeze

    class << self
      # @param [Symbol] key
      # @return [String]
      def build(key, data: nil)
        text = DICTIONARY.fetch key
        return text unless data

        text % data
      rescue => e
        logger.error e.message
        Raven.capture_message(
          e.message,
          tags: {
            key: key,
            data: data
          }
        )
        key.to_s
      end
    end
  end
end
