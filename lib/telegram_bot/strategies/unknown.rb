# frozen_string_literal: true

class TelegramBot
  module Strategies
    # A class for unknown strategy
    class Unknown < Base
      def perform
        bot.state! nil
        bot.send_message message: Texts.build(:do_not_understand),
                         entities: Texts.entities_for(
                           :do_not_understand,
                           url: Intercom.chat_url(bot.chat.id)
                         )
      end
    end
  end
end
