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

      # Convenience accessor for the response body from the original Faraday error.
      # May be a String (raw JSON), Hash, or Array when Faraday's JSON middleware has
      # already parsed the body. Avoids callers needing `e.original_error.try(:response_body)`.
      #
      # @return [String, Hash, Array, nil]
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
      def parsed_error_object
        return @parsed_error_object if defined?(@parsed_error_object)

        @parsed_error_object = extract_error_object
      end

      # @return [Hash, nil]
      def extract_error_object
        body = response_body
        return nil if body.blank?

        parsed = parse_body(body)
        return nil if parsed.nil?

        first_error = extract_first_error(parsed)
        first_error.is_a?(Hash) && first_error.key?('code') ? first_error : nil
      end

      # Converts the response body to a parsed Ruby object.
      # Handles String (JSON), pre-parsed Hash/Array (Faraday JSON middleware), and unknown types.
      #
      # @return [Hash, Array, nil]
      def parse_body(body)
        case body
        when String then JSON.parse(body)
        when Hash, Array then body
        end
      rescue JSON::ParserError, TypeError
        nil
      end

      # Handles both response shapes from the Platform API:
      #   Object format (current production): { "errors": { "code": "...", ... } }
      #   Array format  (target):             { "errors": [{ "code": "...", ... }] }
      #
      # @return [Object, nil]
      def extract_first_error(parsed)
        errors_value = parsed.is_a?(Hash) ? parsed['errors'] : nil
        case errors_value
        when Array then errors_value.first
        when Hash  then errors_value
        end
      end
    end

    # Raised for validation failures (422 Unprocessable Entity)
    class ValidationError < ClientError; end

    # Raised when a requested resource is not found (404)
    class NotFoundError < ClientError; end

    # Raised when a rate is no longer available for booking
    class RateUnavailableError < ClientError; end

    # Raised when a booking (confirmation) request fails
    class BookingError < ClientError; end

    # Raised when a cancellation request fails
    class CancellationError < ClientError; end

    # Raised for unexpected server-side failures (5xx)
    class InternalError < ClientError; end
  end
end
