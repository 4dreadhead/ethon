# frozen_string_literal: true

class TelegramBot
  module Strategies
    # A class for unknown strategy
    class Unknown < Base
      def perform
        bot.state! nil
        bot.send_message message: Texts.build(:do_not_understand)
      end
    end
  end
end
