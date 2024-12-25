# frozen_string_literal: true

module PlatformClient
  # Configuration class
  class Configuration
    attr_writer :base_url

    # The base URL for the API
    #
    # @return [String]
    # @raise [PlatformClient::Errors::NotConfiguredError] if the base URL is not set
    def base_url
      raise PlatformClient::Errors::NotConfiguredError unless @base_url

      @base_url
    end

    # Returns auth provider to get JWT token for requests authentication
    # @return [Object] auth provider
    # @raise [PlatformClient::Errors::NotConfiguredError] if the auth provider is not set
    def auth_provider
      raise PlatformClient::Errors::NotConfiguredError unless @auth_provider

      @auth_provider
    end

    # Sets the auth provider
    #
    # @raise [PlatformClient::Errors::InvalidConfigurationError] if the auth provider does not respond to :get_token
    def auth_provider=(auth_provider)
      raise PlatformClient::Errors::InvalidConfigurationError unless auth_provider.respond_to?(:get_auth_token)

      @auth_provider = auth_provider
    end
  end
end
