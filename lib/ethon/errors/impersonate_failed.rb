# frozen_string_literal: true
module Ethon
  module Errors

    # Raises when option is invalid.
    class ImpersonateFailed < EthonError
      def initialize(browser, code)
        super("Impersonate to #{browser} failed. Error code: #{code}.")
      end
    end
  end
end