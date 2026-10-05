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
require 'platform_client/requests/booking/cancellation'
require 'platform_client/requests/availabilities'
require 'platform_client/requests/room_occupancy'

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
      # @param language [Array<String>] Array of Language codes to get the response in, default is 'en-US'
      #
      # @return [PlatformClient::Responses::Properties]
      def properties(page: nil, limit: nil, country_code: nil, category_ids: [], codes: [], languages: [PlatformClient::DEFAULT_LANGUAGE]) # rubocop:disable Metrics/ParameterLists
        Properties.call(page:, limit:, country_code:, category_ids:, codes:, languages:)
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
      # @param languages [Array<String>] Language codes to get the response in, default is 'ja-JP'
      def rooms(page: nil, limit: nil, property_codes: [], room_codes: [], languages: [PlatformClient::DEFAULT_LANGUAGE])
        Rooms.call(page:, limit:, property_codes:, room_codes:, languages:)
      end

      # ----------------------------------------------------Shopping and Booking-----------------------------------------------------

      # check availability for a property room
      #
      # @param property_code [String] Property code
      # @param room_code [String] Room code
      # @param from_date [String] Check-in date in 'YYYY-MM-DD' format
      # @param to_date [String] Check-out date in 'YYYY-MM-DD' format
      # @param adults_count [Integer] Number of adults, default is nil to fetch availability for all available occupancies
      # @param board_code [String] Boarding (meal) type filter. One of: room_only, breakfast, lunch, dinner,
      #   half_board, full_board, all_inclusive. Default is nil, in which case the Platform returns one best-price
      #   row per boarding type the property offers. Non-room_only values require multi-board support to be enabled
      #   on the Platform; otherwise the request fails with a +PlatformClient::Errors::ValidationError+ (422).
      #
      # @return [PlatformClient::Responses::Availabilities]
      def check_availability(property_code:, from_date:, to_date:, adults_count: nil, room_code: nil, board_code: nil) # rubocop:disable Metrics/ParameterLists
        Availabilities.call(property_code:, room_code:, from_date:, to_date:, adults_count:, board_code:)
      end

      # Check rate for a property room
      #
      # @param property_code [String] Property code
      # @param room_code [String] Room code
      # @param check_in_date [String] Check-in date in 'YYYY-MM-DD' format
      # @param check_out_date [String] Check-out date in 'YYYY-MM-DD' format
      # @param country_code [String] The country code of the traveler's point of sale(country where the shopping transaction is taking place), in ISO 3166-1 alpha-2 format.
      # @param adults_count [Integer] Number of adults, default is 1
      # @param nationality [String] Nationality code(ISO 3166-1 alpha-2 country code) of the guests looking for available packages
      # @param language [String] Language code to get the response in, a subset of BCP47 format that only uses hyphenated pairs of two-digit language and country codes.
      #   default is 'en-US'
      # @param customer_session_id [String] Customer session ID to track the session, default is nil
      # @param board_code [String] Boarding (meal) type to check the rate for. One of: room_only, breakfast, lunch, dinner,
      #   half_board, full_board, all_inclusive. Default is nil, in which case the Platform defaults to room_only.
      #   Non-room_only values require multi-board support to be enabled on the Platform; otherwise the request
      #   fails with a +PlatformClient::Errors::ValidationError+ (422).
      # @return [PlatformClient::Responses::Rate]
      def check_rate(property_code:, room_code:, check_in_date:, check_out_date:, country_code:, adults_count: 1, nationality: PlatformClient::DEFUAULT_NATIONALITY, language: PlatformClient::DEFAULT_LANGUAGE, board_code: nil, customer_session_id: nil) # rubocop:disable Metrics/ParameterLists
        Rate.call(property_code:, room_code:, check_in_date:, check_out_date:, country_code:, adults_count:, nationality:, language:, board_code:, customer_session_id:)
      end

      # Create the booking for a room
      #
      # @param rate_key [String] Rate key of the room to book recieved from the +.check_rate+ endpoint
      # @param client_reference [String] Unique Client reference for the booking
      # @param first_name [String] First name of the guest
      # @param last_name [String] Last name of the guest
      # @param nationality [String] Nationality of the guest
      # @param contact_number [String] Contact number of the guest
      # @param email [String] Email of the guest
      # @param guest_ip [String] IP address of the guest from where the booking is made
      # @param customer_session_id [String] Customer session ID to track the session, default is nil
      #
      # @return [PlatformClient::Responses::Booking::Confirmation]
      def create_booking(rate_key:, client_reference:, first_name:, last_name:, nationality:, contact_number:, email: nil, guest_ip: nil, customer_session_id: nil) # rubocop:disable Metrics/ParameterLists
        Booking::Confirmation.call(rate_key:, client_reference:, first_name:, last_name:, nationality:, contact_number:, email:, guest_ip:, customer_session_id:)
      end

      # Cancel the booking for a room
      #
      # @param client_reference [String] Client reference that was used for the booking
      # @param guest_ip [String] IP address of the guest from where the cancellation is made
      # @param customer_session_id [String] Customer session ID to track the session, default is nil
      #
      # @return [PlatformClient::Responses::Booking::Cancellation]
      def cancel_booking(client_reference:, guest_ip: nil, customer_session_id: nil)
        Booking::Cancellation.call(client_reference:, guest_ip:, customer_session_id:)
      end

      # ---------------------------------------------------------HafH----------------------------------------------------------------

      # Set which adults counts Platform collects availability for, for one room
      #
      # Writes are ordered per room by +changed_at+. Sending the same +changed_at+ with the same set again is an
      # idempotent success, so retries are safe.
      #
      # @param property_code [String] Master property code (4 chars, case-sensitive), sent unchanged
      # @param room_code [String] Master room code, the same values +.rooms+ returns
      # @param adults_counts [Array<Integer>] Distinct adults counts from 1 to 14. +[]+ switches the room off.
      #   Rakuten properties accept only +[]+ or +[2]+
      # @param changed_at [Time, String] When the change happened (not when it is sent), no more than 5 minutes in
      #   the future. A Time is sent with microseconds via +iso8601(6)+; a String must be ISO 8601 with a zone and
      #   is sent as given
      #
      # @raise [PlatformClient::Errors::RoomOccupancyStaleChangeError] (409) a newer change is already stored,
      #   typically a delayed retry; safe to treat as done. +#current+ returns the stored room occupancy
      # @raise [PlatformClient::Errors::RoomOccupancyConflictError] (409) a different set with the same +changed_at+
      #   is already stored; the caller must resolve it. +#current+ returns the stored room occupancy
      # @raise [PlatformClient::Errors::RoomOccupancyRejectedError] (422) see +#error_reason+: UNKNOWN_PROPERTY,
      #   UNKNOWN_ROOM, INVALID_ADULTS_COUNTS, INVALID_CHANGED_AT or UNLINKABLE_PROPERTY. Not retryable
      # @raise [PlatformClient::Errors::InternalError] (5xx) unexpected server-side failure
      #
      # @return [PlatformClient::Responses::RoomOccupancy]
      def update_room_occupancy(property_code:, room_code:, adults_counts:, changed_at:)
        RoomOccupancy.call(property_code:, room_code:, adults_counts:, changed_at:)
      end
    end
  end
end
