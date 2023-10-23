# frozen_string_literal: true

class TelegramBot
  # A class for texts
  class Texts
    DICTIONARY = {
      share_phone_number: "Поделитесь номером телефона",
      share_phone_number_your: "Поделитесь своим номером телефона",
      do_not_understand: "Не понимаю ): Напишите пожалуйста в чат!",
      successfully: "Это успех! Здесь можно задать вопрос!"
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

      # @param [Symbol] key
      # @param [String] url
      # @return [Array]
      def entities_for(key, url: nil)
        case key
        when :do_not_understand
          [{
            type: :text_link,
            url:,
            offset: 14, # +Не понимаю ): +
            length: 26  # +Напишите пожалуйста в чат!+
          }]
        when :successfully
          [{
            type: :text_link,
            url:,
            offset: 11, # +Это успех! +
            length: 26  # +Здесь можно задать вопрос!+
          }]
        else []
        end
      end
    end
  end
end
