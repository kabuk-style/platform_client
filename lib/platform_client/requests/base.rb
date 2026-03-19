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
      rescue Faraday::ClientError => e # Handle 4xx errors from PlatformClient
        # TODO: For now just wrap the Faraday client error and re-raise it. Later we can handle specific errors.
        raise PlatformClient::Errors::ClientError, e
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

      # Returns the request parameters by excluding the customer_session_id from attributes
      # and removing blank values.
      # +customer_session_id+ is sent in the headers instead of the request body. see #headers
      #
      # @return [Hash] the request parameters hash with non-blank values
      def params
        attributes.except('customer_session_id').compact_blank
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
          'Customer-Session-Id' => attributes['customer_session_id'],
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
    end
  end
end
