# frozen_string_literal: true

require 'platform_client/requests/end_point'
require 'platform_client/requests/base'
require 'platform_client/requests/paginated'
require 'platform_client/requests/amenities'
require 'platform_client/requests/chains'
require 'platform_client/requests/facilities'
require 'platform_client/requests/properties'
require 'platform_client/requests/property_categories'
require 'platform_client/requests/room_categories'
require 'platform_client/requests/rooms'
require 'platform_client/requests/rate'
require 'platform_client/requests/booking/confirmation'

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

      # Get list of properties
      #
      # @param page [Integer] Page number, pass nil to get the first page, default is nil to get the first page
      # @param limit [Integer] Number of items per page, pass nil to get the default number of items, default is nil to get the default number of items
      # @param country_code [String] ISO 3166-1 alpha-2 country code to filter properties by, default is nil to get properties from all countries
      # @param category_ids [Array<String>] Array of property category IDs(see +.property_categories+) to filter properties by, default is [] to get properties from all categories
      # @param codes [Array<String>] Array of property codes to filter properties by, default is [] to get properties by all codes
      # @param language [String] Language code to get the response in, default is 'en-US'
      #
      # @return [PlatformClient::Responses::Properties]
      def properties(page: nil, limit: nil, country_code: nil, category_ids: [], codes: [], language: PlatformClient::DEFAULT_LANGUAGE) # rubocop:disable Metrics/ParameterLists
        Properties.call(page:, limit:, country_code:, category_ids:, codes:, language:)
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

      # Get list of rooms for given properties
      #
      # @param page [Integer] Page number, pass nil to get the first page
      # @param limit [Integer] Number of items per page, pass nil to get the default number of items
      # @param property_codes [Array<String>] Array of property codes to get rooms for
      # @param room_codes [Array<String>] Array of room codes to get rooms for
      # @param language [String] Language code to get the response in, default is 'ja-JP'
      def rooms(page: nil, limit: nil, property_codes: [], room_codes: [], language: PlatformClient::DEFAULT_LANGUAGE)
        Rooms.call(page:, limit:, property_codes:, room_codes:, language:)
      end

      # ----------------------------------------------------Booking-----------------------------------------------------

      # Check rate for a property room
      #
      # @param property_code [String] Property code
      # @param room_code [String] Room code
      # @param check_in_date [String] Check-in date in 'YYYY-MM-DD' format
      # @param check_out_date [String] Check-out date in 'YYYY-MM-DD' format
      # @param adults_count [Integer] Number of adults, default is 1
      #
      # @return [PlatformClient::Responses::Rate]
      def check_rate(property_code:, room_code:, check_in_date:, check_out_date:, adults_count: 1)
        Rate.call(property_code:, room_code:, check_in_date:, check_out_date:, adults_count:)
      end

      # Create the booking for a room
      #
      # @param rate_key [String] Rate key of the room to book recieved from the +.check_rate+ endpoint
      # @param client_reference [String] Unique Client reference for the booking
      # @param first_name [String] First name of the guest
      # @param last_name [String] Last name of the guest
      # @param nationality [String] Nationality of the guest
      # @param contact_number [String] Contact number of the guest
      #
      # @return [PlatformClient::Responses::Booking::Confirmation]
      def create_booking(rate_key:, client_reference:, first_name:, last_name:, nationality:, contact_number:) # rubocop:disable Metrics/ParameterLists
        Booking::Confirmation.call(rate_key:, client_reference:, first_name:, last_name:, nationality:, contact_number:)
      end
    end
  end
end
