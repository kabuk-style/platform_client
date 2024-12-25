# frozen_string_literal: true

module PlatformClient
  # Custom errors
  module Errors
    class BaseError < StandardError; end
    class NotConfiguredError < BaseError; end
    class InvalidConfigurationError < BaseError; end
    class InvalidRequestError < BaseError; end

    # Raised when a request to the API fails
    class ClientError < BaseError
      attr_reader :original_error

      # @param original_error [Faraday::ClientError]
      def initialize(original_error)
        @original_error = original_error

        super
      end
    end
  end
end
