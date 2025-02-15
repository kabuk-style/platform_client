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
        amenities: {
          uri: '/api/amenities',
          method: :get,
          type: :content,
        },
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
        properties: {
          uri: '/api/properties',
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
        rooms: {
          uri: '/api/rooms',
          method: :get,
          type: :content,
        },
        rate: {
          uri: '/api/check_rate',
          method: :get,
          type: :shopping,
        },
        booking: {
          confirmation: {
            uri: '/api/bookings',
            method: :post,
            type: :shopping,
          },
          cancellation: {
            uri: '/api/bookings/@client_reference',
            method: :delete,
            type: :shopping,
          },
        },
      }.freeze

      class << self
        # Find an endpoint by API name
        #
        # This method looks up an endpoint using a name derived from the API class name,
        # transforming it into an array of symbols. It allows finding deeply nested
        # endpoints using an array-style lookup.
        #
        # @param name [Array<Symbol>, Symbol, String] The endpoint name.
        #   - e.g., `:login` for `"PlatformClient::Requests::Login"`
        #   - e.g., `[:get_status]` for `"PlatformClient::Requests::GetStatus"`
        #   - e.g., `[:booking, :confirmation]` for `"PlatformClient::Requests::Booking::Confirmation"`
        # @return [EndPoint] The found endpoint.
        def find!(name)
          new(**ENDPOINTS.dig(*name))
        end
      end

      attribute :uri
      attribute :method
      attribute :type
    end
  end
end
