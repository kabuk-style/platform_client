# frozen_string_literal: true

require 'platform_client/requests/end_point'
require 'platform_client/requests/base'
require 'platform_client/requests/paginated'
require 'platform_client/requests/amenities'
require 'platform_client/requests/chains'
require 'platform_client/requests/facilities'
require 'platform_client/requests/property_categories'
require 'platform_client/requests/room_categories'

module PlatformClient
  # Wrapper over requests
  module Requests
    class << self
      # Get list of amenities
      #
      # @param page [Integer] Page number, pass nil to get the first page
      # @param limit [Integer] Number of items per page, pass nil to get the default number of items
      #
      # @return [PlatformClient::Responses::Amenities]
      def amenities(page: nil, limit: nil)
        Amenities.call(page:, limit:)
      end

      # Get list of chains
      #
      # @param page [Integer] Page number, pass nil to get the first page
      # @param limit [Integer] Number of items per page, pass nil to get the default number of items
      #
      # @return [PlatformClient::Responses::Chains]
      def chains(page: nil, limit: nil)
        Chains.call(page:, limit:)
      end

      # Get list of facilities
      #
      # @param page [Integer] Page number, pass nil to get the first page
      # @param limit [Integer] Number of items per page, pass nil to get the default number of items
      #
      # @return [PlatformClient::Responses::Facilities]
      def facilities(page: nil, limit: nil)
        Facilities.call(page:, limit:)
      end

      # Get list of property categories
      #
      # @param page [Integer] Page number, pass nil to get the first page
      # @param limit [Integer] Number of items per page, pass nil to get the default number of items
      #
      # @return [PlatformClient::Responses::PropertyCategories]
      def property_categories(page: nil, limit: nil)
        PropertyCategories.call(page:, limit:)
      end

      # Get list of room categories
      #
      # @param page [Integer] Page number, pass nil to get the first page
      # @param limit [Integer] Number of items per page, pass nil to get the default number of items
      #
      # @return [PlatformClient::Responses::RoomCategories]
      def room_categories(page: nil, limit: nil)
        RoomCategories.call(page:, limit:)
      end
    end
  end
end
