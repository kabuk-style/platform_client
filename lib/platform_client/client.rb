# frozen_string_literal: true

require 'faraday/gzip'

module PlatformClient
  # Kabuk Platform API client
  class Client
    def connection
      @connection ||= Faraday.new(url: base_url) do |conn|
        # set the timeout for the connection. Default is 60 seconds
        conn.options.timeout = 180

        # Sets the Content-Type header to application/json on each request.
        # Also, if the request body is a Hash, it will automatically be encoded as JSON.
        conn.request :json

        # Authenticates the request with a Bearer token.
        conn.request :authorization, 'Bearer', -> { auth_provider.get_auth_token }

        # Parses JSON response bodies.
        # If the response body is not valid JSON, it will raise a Faraday::ParsingError.
        conn.response :json

        # Logs requests and responses.
        # By default, it only logs the request method and URL, and the request/response headers.
        conn.response :logger

        # Raises an error on 4xx and 5xx responses.
        conn.response :raise_error

        # Adds the necessary Accept-Encoding headers and automatically decompresses the response.
        conn.request :gzip

        # defaults to :net_http
        conn.adapter Faraday.default_adapter
      end
    end

    private

    delegate :base_url, :auth_provider, to: :config

    def config
      @config ||= PlatformClient.configuration
    end
  end
end
