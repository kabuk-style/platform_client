# frozen_string_literal: true

module PlatformClient
  module Responses
    # Represents the response from the Kabuk Platform API for the
    # put /api/hafh/properties/:property_code/rooms/:room_code/occupancy endpoint
    class RoomOccupancy < Base
      # @return [Hash<String, Object>] the stored room occupancy
      def room_occupancy
        result['room_occupancy']
      end

      # @return [String] master property code
      def property_code = room_occupancy['property_code']

      # @return [String] master room code
      def room_code = room_occupancy['room_code']

      # @return [String] supplier of the property, e.g. 'expedia' or 'rakuten'
      def supplier = room_occupancy['supplier']

      # @return [Array<Integer>] adults counts Platform collects for the room; [] means the room is off
      def adults_counts = room_occupancy['adults_counts']

      # @return [String, nil] stored changed_at as a UTC ISO 8601 string with microseconds
      def changed_at = room_occupancy['changed_at']
    end
  end
end
