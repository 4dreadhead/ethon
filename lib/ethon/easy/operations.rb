# frozen_string_literal: true
module Ethon
  class Easy
    # This module contains the logic to prepare and perform
    # an easy.
    module Operations
      # Returns a pointer to the curl easy handle.
      #
      # @example Return the handle.
      #   easy.handle
      #
      # @return [ FFI::Pointer ] A pointer to the curl easy handle.
      def handle
        @handle ||= set_impersonate(
          FFI::AutoPointer.new(
            Curl.easy_init,
            Curl.method(:easy_cleanup)
          )
        )
      end

      # Sets a pointer to the curl easy handle.
      # @param [ ::FFI::Pointer ] Easy handle that will be assigned.
      def handle=(h)
        @handle = set_impersonate(h)
      end

      # Perform the easy request.
      #
      # @example Perform the request.
      #   easy.perform
      #
      # @return [ Integer ] The return code.
      def perform
        @return_code = Curl.easy_perform(handle)
        if Ethon.logger.debug?
          Ethon.logger.debug { "ETHON: performed #{log_inspect}" }
        end
        complete
        @return_code
      end

      # Clean up the easy.
      #
      # @example Perform clean up.
      #   easy.cleanup
      #
      # @return the result of the free which is nil
      def cleanup
        handle.free
      end

      # Prepare the easy. Options, headers and callbacks
      # were set.
      #
      # @example Prepare easy.
      #   easy.prepare
      #
      # @deprecated It is no longer necessary to call prepare.
      def prepare
        Ethon.logger.warn(
          "ETHON: It is no longer necessary to call "+
          "Easy#prepare. It's going to be removed "+
          "in future versions."
        )
      end

      # Set impersonate browser from Ethon::Curl::Config
      #
      # @param [ ::FFI::Pointer ] easy_pointer pointer to easy instance.
      def set_impersonate(easy_pointer)
        impersonate = Curl::Config.impersonate
        return easy_pointer unless impersonate

        raise Ethon::Errors::ImpersonateFailed.new(impersonate, "libcurl-impersonate.so not found") unless
          Curl.respond_to?(:easy_impersonate)

        code = Curl.easy_impersonate(easy_pointer, impersonate, 0)
        raise Ethon::Errors::ImpersonateFailed.new(impersonate, code) unless result == 0

        easy_pointer
      end
    end
  end
end
