# frozen_string_literal: true

require 'active_model'

module PlatformClient
  module Requests
    # Represents an API endpoint with its URI, type of the API and HTTP method requirement.
    # Provides functionality to find and instantiate endpoints by name.
    #
    # @example Find and use an endpoint
    #   endpoint = PlatformClient::Requests::EndPoint.find!(:chains)
    #   puts endpoint.uri    # => '/api/chains'
    #   puts endpoint.method # => :get
    #   puts endpoint.type # => :content
    class EndPoint
      include ActiveModel::API
      include ActiveModel::Attributes

      ENDPOINTS = {
        chains: {
          uri: '/api/chains',
          method: :get,
          type: :content,
        },
        facilities: {
          uri: '/api/facilities',
          method: :get,
          type: :content,
        },
        property_categories: {
          uri: '/api/property_categories',
          method: :get,
          type: :content,
        },
        room_categories: {
          uri: '/api/room_categories',
          method: :get,
          type: :content,
        },
      }.freeze

      class << self
        # Find an endpoint by API name
        # @param name [Symbol,String] the name of the endpoint derived from the API name by transforming it to snake_case
        #                             e.g. 'login' for 'Login', 'get_status' for 'GetStatus'
        # @return [EndPoint]
        def find!(name)
          new(**ENDPOINTS.fetch(name.to_sym))
        end
      end

      attribute :uri
      attribute :method
      attribute :type
    end
  end
end
