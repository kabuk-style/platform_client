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

      # Convenience accessor for the raw response body string from the original Faraday error.
      # Avoids callers needing `e.original_error.try(:response_body)`.
      #
      # @return [String, nil]
      def response_body
        original_error.try(:response_body)
      end

      # Returns true when the API returned a structured error response (new format).
      # Structured format: {"errors": [{"code": "...", "message": "...", ...}]}
      # Legacy format: {"errors": ["string message"]} or any non-JSON body
      #
      # @return [Boolean]
      def structured?
        parsed_error_object.is_a?(Hash) && parsed_error_object.key?('code')
      end

      # @return [String, nil] UPPERCASE error code e.g. "RATE_UNAVAILABLE"
      def error_code
        parsed_error_object&.fetch('code', nil)
      end

      # @return [String, nil] Human-friendly error message from the Platform API
      def error_message
        parsed_error_object&.fetch('message', nil)
      end

      # @return [String, nil] Technical reason code e.g. "NO_ROOM_ONLY"
      def error_reason
        parsed_error_object&.fetch('reason', nil)
      end

      # @return [Hash, nil] Additional error details (may include original_error_message)
      def error_details
        parsed_error_object&.fetch('details', nil)
      end

      # @return [String, nil] Request ID for distributed tracing across services
      def request_id
        parsed_error_object&.fetch('request_id', nil)
      end

      # Returns the human-friendly Platform error message when the response is structured,
      # otherwise falls back to the original Faraday error message.
      #
      # @return [String]
      def message
        error_message.presence || original_error.message
      end

      private

      # Parses the response body and returns the first structured error object, or nil.
      # Uses memoization with defined? guard so a nil result is only computed once.
      #
      # @return [Hash, nil]
      def parsed_error_object # rubocop:disable Metrics/MethodLength
        return @parsed_error_object if defined?(@parsed_error_object)

        body = response_body
        if body.blank?
          @parsed_error_object = nil
          return @parsed_error_object
        end

        parsed = JSON.parse(body)
        errors_array = parsed.is_a?(Hash) ? parsed['errors'] : nil
        first_error = errors_array.is_a?(Array) ? errors_array.first : nil
        # Only treat as structured if the first element is a Hash (new format).
        # Legacy format has strings in the errors array — return nil for those.
        @parsed_error_object = first_error.is_a?(Hash) ? first_error : nil
      rescue JSON::ParserError
        @parsed_error_object = nil
      end
    end
  end
end
