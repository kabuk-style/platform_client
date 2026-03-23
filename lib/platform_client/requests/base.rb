# frozen_string_literal: true

module PlatformClient
  module Requests
    # Base class for all requests
    class Base
      include ActiveModel::API
      include ActiveModel::Attributes

      class << self
        def call(...)
          new(...).call
        end
      end

      def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        # Make the request
        response = connection.public_send(endpoint.method, endpoint_uri) do |request|
          case endpoint.method
          when :get, :delete
            request.params = params
          when :post, :put
            request.body = params.to_json
          else
            raise PlatformClient::Errors::InvalidRequest, "Unsupported HTTP method #{endpoint.method}"
          end

          request.headers = headers
        end

        # Build the response object
        response_class.new(response)
      rescue Faraday::ClientError, Faraday::ServerError => e
        raise build_error(e)
      end

      private

      # Get the endpoint URI for the request
      #
      # @return [String]
      def endpoint_uri
        uri = endpoint.uri.dup

        # Replace URI path params with actual values
        uri_params.each do |k, v|
          uri.gsub!("@#{k}", v)
        end

        uri
      end

      def endpoint
        return @endpoint if defined? @endpoint

        endpoint_name = self.class.name.gsub('PlatformClient::Requests::', '').underscore.split('/').map(&:to_sym)
        @endpoint = PlatformClient::Requests::EndPoint.find!(endpoint_name)
      end

      def params
        attributes.compact_blank
      end

      def uri_params
        {}
      end

      def headers
        {
          'Content-Type' => 'application/json',
          'Accept-Encoding' => 'gzip',
          'User-Agent' => "API Client for Kabuk Platform - #{client_app_env}",
          'X-Client-App-Env' => client_app_env,
        }.compact_blank
      end

      def response_class
        self.class.name.gsub('Requests', 'Responses').constantize
      end

      # Get the connection object for the request
      #
      # @param base_url [String] the base URL for the request. Content and Shopping APIs have different base URL.
      def connection
        @connection ||= Client.new.connection
      end

      def client_app_env
        PlatformClient.configuration.client_app_env
      end

      # Maps structured error codes returned by the Platform API to specific error subclasses.
      ERROR_CODE_MAP = {
        'RATE_UNAVAILABLE' => PlatformClient::Errors::RateUnavailableError,
        'BOOKING_ERROR' => PlatformClient::Errors::BookingError,
        'CANCELLATION_ERROR' => PlatformClient::Errors::CancellationError,
        'NOT_FOUND' => PlatformClient::Errors::NotFoundError,
        'VALIDATION_ERROR' => PlatformClient::Errors::ValidationError,
      }.freeze

      # Wraps a Faraday error in the most specific PlatformClient error subclass available.
      # When the response body is structured (new format) the error_code is used for routing.
      # When the response body is legacy / non-JSON, the base ClientError is raised so that
      # all existing rescue clauses continue to work.
      #
      # @param faraday_error [Faraday::Error]
      # @return [PlatformClient::Errors::ClientError]
      def build_error(faraday_error)
        return PlatformClient::Errors::InternalError.new(faraday_error) if faraday_error.is_a?(Faraday::ServerError)

        error = PlatformClient::Errors::ClientError.new(faraday_error)
        structured_error_for(error) || error
      end

      def structured_error_for(error)
        return unless error.structured?

        klass = ERROR_CODE_MAP[error.error_code]
        klass&.new(error.original_error)
      end
    end
  end
end
